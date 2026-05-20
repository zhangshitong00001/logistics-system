from sqlalchemy import Column, Integer, String, DateTime, Numeric, Date, Text, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class Reconciliation(Base):
    """对账表"""
    __tablename__ = 'reconciliation'

    id = Column(Integer, primary_key=True, autoincrement=True)
    recon_no = Column(String(64), unique=True, nullable=False, comment='对账单号')
    partner = Column(String(128), comment='合作方')
    cycle_start = Column(Date, comment='周期开始')
    cycle_end = Column(Date, comment='周期结束')
    order_amount = Column(Numeric(18, 2), default=0, comment='订单金额')
    logistics_fee = Column(Numeric(18, 2), default=0, comment='物流费用')
    diff_amount = Column(Numeric(18, 2), default=0, comment='差异金额')
    diff_count = Column(Integer, default=0, comment='差异笔数')
    status = Column(Integer, default=0, comment='状态:0待对账1对账中2已完成3差异待处理')
    operator = Column(String(64), comment='操作人')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class Settlement(Base):
    """结算单表"""
    __tablename__ = 'settlement'

    id = Column(Integer, primary_key=True, autoincrement=True)
    settle_no = Column(String(64), unique=True, nullable=False, comment='结算单号')
    recon_id = Column(Integer, ForeignKey('reconciliation.id'), comment='对账ID')
    partner = Column(String(128), comment='合作方')
    settle_cycle_start = Column(Date, comment='结算周期开始')
    settle_cycle_end = Column(Date, comment='结算周期结束')
    settle_amount = Column(Numeric(18, 2), default=0, comment='结算金额')
    direction = Column(String(16), comment='方向:payable应付/receivable应收')
    status = Column(Integer, default=0, comment='状态:0待审核1已通过2已驳回3已完成')
    audit_comment = Column(Text, comment='审核意见')
    submitter = Column(String(64), comment='提交人')
    auditor = Column(String(64), comment='审核人')
    audit_time = Column(DateTime, comment='审核时间')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
