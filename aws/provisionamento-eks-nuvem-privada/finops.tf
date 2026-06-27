data "aws_caller_identity" "current" {}

# ═══════════════════════════════════════════════════════════
# FINOPS — Orçamento, Alertas e Controle de Custos AWS EKS
# ═══════════════════════════════════════════════════════════

# ── 1. AWS Budget — alerta por limiar de custo mensal ──────
resource "aws_budgets_budget" "eks_monthly" {
  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_limit
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  cost_filter {
    name   = "TagKeyValue"
    values = ["user:Project$${var.project_name}"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.budget_alert_threshold_pct
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
}

# ── 2. Cost Allocation Tags — visibilidade granular ─────────
resource "aws_ce_cost_allocation_tag" "project" {
  tag_key = "Project"
  status  = "Active"
}

resource "aws_ce_cost_allocation_tag" "environment" {
  tag_key = "Environment"
  status  = "Active"
}

resource "aws_ce_cost_allocation_tag" "cost_center" {
  tag_key = "CostCenter"
  status  = "Active"
}

resource "aws_ce_cost_allocation_tag" "team" {
  tag_key = "Team"
  status  = "Active"
}

# ── 3. Cost Anomaly Detection — alertas de gastos anômalos ──
resource "aws_ce_anomaly_monitor" "eks" {
  name              = "${var.project_name}-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "eks" {
  name      = "${var.project_name}-anomaly-subscription"
  frequency = "DAILY"

  monitor_arn_list = [aws_ce_anomaly_monitor.eks.arn]

  subscriber {
    type    = "EMAIL"
    address = var.budget_alert_emails[0]
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
      values        = ["20"]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}

# ── 4. CloudWatch Alarms — custo estimado EC2 ───────────────
resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  alarm_name          = "${var.project_name}-estimated-charges"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400
  statistic           = "Maximum"
  threshold           = var.monthly_budget_limit
  alarm_description   = "Alerta FinOps: custo estimado excedeu limite mensal de USD ${var.monthly_budget_limit}"
  alarm_actions       = [aws_sns_topic.finops_alerts.arn]

  dimensions = {
    Currency = "USD"
  }

  tags = { Name = "${var.project_name}-billing-alarm" }
}

resource "aws_sns_topic" "finops_alerts" {
  name = "${var.project_name}-finops-alerts"

  tags = { Name = "${var.project_name}-finops-sns" }
}

resource "aws_sns_topic_subscription" "finops_email" {
  for_each  = toset(var.budget_alert_emails)
  topic_arn = aws_sns_topic.finops_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# ── 5. Savings Plans / Reserved Instances — recomendação ────
# Recurso informativo: use o Cost Explorer para comprar Savings Plans
# após 2-4 semanas de baseline de uso real.
resource "aws_cloudwatch_dashboard" "finops" {
  dashboard_name = "${var.project_name}-finops"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "Custo Estimado Total (USD)"
          period = 86400
          stat   = "Maximum"
          metrics = [
            ["AWS/Billing", "EstimatedCharges", "Currency", "USD"]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "Utilização CPU — Nós EKS"
          period = 300
          stat   = "Average"
          metrics = [
            ["AWS/EC2", "CPUUtilization", { label = "Avg CPU nodes" }]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "NAT Gateway — Bytes Processados"
          period = 3600
          stat   = "Sum"
          metrics = [
            ["AWS/NATGateway", "BytesOutToDestination"]
          ]
          view = "timeSeries"
        }
      },
      {
        type   = "metric"
        width  = 12
        height = 6
        properties = {
          title  = "ECR — Storage Utilizado"
          period = 86400
          stat   = "Average"
          metrics = [
            ["AWS/ECR", "RepositoryPullCount"]
          ]
          view = "timeSeries"
        }
      }
    ]
  })
}

# ── 6. AWS Compute Optimizer — habilitado para recomendações ─
resource "aws_computeoptimizer_enrollment_status" "eks" {
  status                     = "Active"
  include_member_accounts    = false
}

# ── 7. Scheduled Scaling — desligar nós fora do horário ─────
# FinOps: scale-in automático de nós em horário não-comercial (dev/staging)
resource "aws_autoscaling_schedule" "scale_down_night" {
  count                  = var.environment != "prod" ? 1 : 0
  scheduled_action_name  = "${var.project_name}-scale-down-night"
  min_size               = 0
  max_size               = var.self_managed_node_max
  desired_capacity       = 0
  recurrence             = "0 22 * * MON-FRI"
  time_zone              = "America/Sao_Paulo"
  autoscaling_group_name = aws_autoscaling_group.self_managed.name
}

resource "aws_autoscaling_schedule" "scale_up_morning" {
  count                  = var.environment != "prod" ? 1 : 0
  scheduled_action_name  = "${var.project_name}-scale-up-morning"
  min_size               = var.self_managed_node_min
  max_size               = var.self_managed_node_max
  desired_capacity       = var.self_managed_node_desired
  recurrence             = "0 7 * * MON-FRI"
  time_zone              = "America/Sao_Paulo"
  autoscaling_group_name = aws_autoscaling_group.self_managed.name
}
