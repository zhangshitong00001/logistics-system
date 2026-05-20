from sqlalchemy import Column, Integer, String, DateTime, Numeric, Text
from sqlalchemy.sql import func
from app.core.database import Base


class BillingRule(Base):
    """计费规则表"""
    __tablename__ = 'billing_rule'

    id = Column(Integer, primary_key=True, autoincrement=True)
    rule_name = Column(String(128), nullable=False, comment='规则名称')
    fee_type = Column(String(16), nullable=False, comment='费用类型:transport/storage/packaging/surcharge')
    charge_method = Column(String(16), comment='计费方式:weight/volume/fixed')
    base_rate = Column(Numeric(18, 4), comment='基础费率')
    rate_unit = Column(String(16), comment='费率单位')
    currency = Column(String(8), default='CNY', comment='币种')
    tier_config = Column(Text, comment='阶梯配置(JSON)')
    applicable_condition = Column(Text, comment='适用条件')
    priority = Column(Integer, default=0, comment='优先级')
    status = Column(Integer, default=1, comment='状态:1启用0禁用')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
