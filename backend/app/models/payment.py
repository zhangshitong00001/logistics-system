from sqlalchemy import Column, Integer, String, DateTime, Numeric, Text, ForeignKey
from sqlalchemy.sql import func
from app.core.database import Base


class Payment(Base):
    """支付记录表"""
    __tablename__ = 'payment'

    id = Column(Integer, primary_key=True, autoincrement=True)
    payment_no = Column(String(64), unique=True, nullable=False, comment='支付单号')
    settle_id = Column(Integer, ForeignKey('settlement.id'), comment='结算单ID')
    pay_amount = Column(Numeric(18, 2), default=0, comment='支付金额')
    pay_channel = Column(String(16), comment='支付渠道:bank/alipay/wechat')
    pay_time = Column(DateTime, comment='支付时间')
    status = Column(Integer, default=0, comment='状态:0待支付1支付中2已支付3已退款')
    remark = Column(Text, comment='备注')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)


class Invoice(Base):
    """发票表"""
    __tablename__ = 'invoice'

    id = Column(Integer, primary_key=True, autoincrement=True)
    invoice_no = Column(String(64), unique=True, nullable=False, comment='发票号')
    payment_id = Column(Integer, ForeignKey('payment.id'), comment='支付ID')
    invoice_type = Column(String(16), comment='发票类型:vat增值税/normal普通')
    amount = Column(Numeric(18, 2), default=0, comment='金额')
    buyer_name = Column(String(128), comment='购方名称')
    buyer_tax_no = Column(String(32), comment='购方税号')
    invoice_file_path = Column(String(512), comment='发票文件路径')
    status = Column(Integer, default=0, comment='状态:0待开票1已开票2已作废')
    create_time = Column(DateTime, server_default=func.now())
    update_time = Column(DateTime, server_default=func.now(), onupdate=func.now())
    deleted = Column(Integer, default=0)
