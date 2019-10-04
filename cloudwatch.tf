resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "${var.name}-${var.environment}-node-cpureservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.rabbit-node.name
  }

  alarm_description = "Scale up if the cpu reservation is above 70% for 10 minutes"
  alarm_actions     = [aws_autoscaling_policy.rabbit-node-scale-up.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "${var.name}-${var.environment}-node-memoryreservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.rabbit-node.name
  }

  alarm_description = "Scale up if the memory reservation is above 70% for 10 minutes"
  alarm_actions     = [aws_autoscaling_policy.rabbit-node-scale-up.arn]

  lifecycle {
    create_before_destroy = true
  }

  # This is required to make cloudwatch alarms creation sequential, AWS doesn't
  # support modifying alarms concurrently.
  depends_on = ["aws_cloudwatch_metric_alarm.node_cpu_high"]
}

resource "aws_cloudwatch_metric_alarm" "node_cpu_low" {
  alarm_name          = "${var.name}-${var.environment}-node-cpureservation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.rabbit-node.name
  }

  alarm_description = "Scale down if the cpu reservation is below 20% for 10 minutes"
  alarm_actions     = [aws_autoscaling_policy.rabbit-node-scale-down.arn]

  lifecycle {
    create_before_destroy = true
  }

  # This is required to make cloudwatch alarms creation sequential, AWS doesn't
  # support modifying alarms concurrently.
  depends_on = ["aws_cloudwatch_metric_alarm.node_memory_high"]
}

resource "aws_cloudwatch_metric_alarm" "node_memory_low" {
  alarm_name          = "${var.name}-${var.environment}-node-memoryreservation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.rabbit-node.name
  }

  alarm_description = "Scale down if the memory reservation is below 20% for 10 minutes"
  alarm_actions     = [aws_autoscaling_policy.rabbit-node-scale-down.arn]

  lifecycle {
    create_before_destroy = true
  }

  # This is required to make cloudwatch alarms creation sequential, AWS doesn't
  # support modifying alarms concurrently.
  depends_on = ["aws_cloudwatch_metric_alarm.node_cpu_low"]
}
