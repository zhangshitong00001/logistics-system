"""邮箱发送工具 - 通过 163 SMTP 发送验证码"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import get_settings


def send_email_code(to_email: str, code: str, purpose: str = "login") -> None:
    """发送验证码邮件"""
    settings = get_settings()

    subject_map = {
        "login": "跨境物流系统 - 登录验证码",
        "register": "跨境物流系统 - 注册验证码",
        "reset": "跨境物流系统 - 重置密码验证码",
    }
    subject = subject_map.get(purpose, "跨境物流系统 - 验证码")

    body = f"""\
<div style="max-width:480px;margin:0 auto;padding:24px;font-family:'Microsoft YaHei',sans-serif;background:#f8f9fc;border-radius:12px;">
  <div style="text-align:center;padding:24px 0;">
    <div style="width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#3b82f6,#6366f1);margin:0 auto 12px;display:flex;align-items:center;justify-content:center;color:#fff;font-size:24px;">📦</div>
    <h2 style="margin:0;color:#333;font-size:20px;">跨境物流业务系统</h2>
    <p style="color:#999;font-size:13px;margin:4px 0 0;">China-Kazakhstan Logistics Platform</p>
  </div>
  <div style="background:#fff;border-radius:12px;padding:32px 24px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.06);">
    <p style="color:#666;font-size:14px;margin:0 0 16px;">您的验证码为：</p>
    <div style="font-size:42px;font-weight:700;letter-spacing:8px;color:#3b82f6;background:#f0f5ff;padding:16px 24px;border-radius:12px;display:inline-block;font-family:monospace;">{code}</div>
    <p style="color:#999;font-size:12px;margin:16px 0 0;">验证码 5 分钟内有效，请勿泄露给他人</p>
  </div>
  <p style="text-align:center;color:#bbb;font-size:11px;margin-top:24px;">此邮件由系统自动发送，请勿回复</p>
</div>"""

    msg = MIMEMultipart("alternative")
    msg["From"] = settings.SMTP_USER
    msg["To"] = to_email
    msg["Subject"] = subject
    msg.attach(MIMEText(body, "html", "utf-8"))

    password = settings.SMTP_PASSWORD
    if not password:
        raise RuntimeError("SMTP 密码未配置，请在 .env 中设置 SMTP_PASSWORD")

    with smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT) as server:
        server.login(settings.SMTP_USER, password)
        server.sendmail(settings.SMTP_USER, to_email, msg.as_string())
