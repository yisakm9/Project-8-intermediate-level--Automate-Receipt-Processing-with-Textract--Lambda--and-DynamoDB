# resource.aws_ses_email_identity "email_identity": Registers an email address with SES.
# AWS will send a verification link to this email address. You must click it before SES can send emails from it.
resource "aws_ses_email_identity" "email_identity" {
  email = var.notification_email
}
