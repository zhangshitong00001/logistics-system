from sqlalchemy import Column, Integer, String, DateTime, Text
from sqlalchemy.sql import func
from app.core.database import Base


class AlertRule(Base):
    """预警规则表"""
    __tablename__ = 'alert_rule'

    id = Column(Integer, primary_key=True, autoincrement=True)
    rule_name = Column(String(128), nullable=False, comment='规则名称')
    alert_type = Column(String(32), nullable=False, comment='预警类型:delay/customs/transport/sign/reconciliation')
    severity = Column(String(16), default='medium', comment='严重级别:low/medium/high/critical')
    trigger_condition = Column(Text, comment='触发条件')
    threshold_value = Column(String(64), comment='阈值')
    notify_method = Column(String(64), comment='通知方式')
    notify_role_id = Column(Integer, comment='通知角色ID')
    status = Column(Integer, default=1, comment='状态:1启用0禁用')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class AlertRecord(Base):
    """预警记录表"""
    __tablename__ = 'alert_record'

    id = Column(Integer, primary_key=True, autoincrement=True)
    batch_no = Column(String(64), comment='关联批次号')
    alert_type = Column(String(32), nullable=False, comment='预警类型')
    severity = Column(String(16), default='medium', comment='严重级别')
    content = Column(Text, comment='预警内容')
    status = Column(Integer, default=0, comment='状态:0待处理1处理中2已处理3已关闭')
    handled_by = Column(String(64), comment='处理人')
    handle_result = Column(Text, comment='处理结果')
    handle_time = Column(DateTime, comment='处理时间')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
