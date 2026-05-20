from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.payment import Payment, Invoice

router = APIRouter(prefix="/api/v1/payment", tags=["支付开票管理"])


@router.get("/list")
def get_payments(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """支付记录列表"""
    q = db.query(Payment).filter(Payment.deleted == 0)
    if status >= 0:
        q = q.filter(Payment.status == status)

    total = q.count()
    records = q.order_by(Payment.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "payment_no": r.payment_no,
                "pay_amount": float(r.pay_amount) if r.pay_amount else 0,
                "pay_channel": r.pay_channel, "status": r.status,
                "pay_time": str(r.pay_time) if r.pay_time else None,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("")
def create_payment(
    settle_id: int = 0,
    pay_amount: float = 0,
    pay_channel: str = "bank",
    db: Session = Depends(get_db),
):
    """发起支付"""
    import uuid
    payment_no = f"PAY-{uuid.uuid4().hex[:8].upper()}"

    from datetime import datetime, timezone
    payment = Payment(
        payment_no=payment_no,
        settle_id=settle_id if settle_id else None,
        pay_amount=pay_amount,
        pay_channel=pay_channel,
        pay_time=datetime.now(timezone.utc),
        status=2,  # 默认已完成
    )
    db.add(payment)
    db.commit()

    return {"code": 200, "data": {"payment_id": payment.id, "payment_no": payment_no}}


@router.get("/invoice/list")
def get_invoices(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """发票列表"""
    q = db.query(Invoice).filter(Invoice.deleted == 0)
    if status >= 0:
        q = q.filter(Invoice.status == status)

    total = q.count()
    records = q.order_by(Invoice.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "invoice_no": r.invoice_no,
                "invoice_type": r.invoice_type,
                "amount": float(r.amount) if r.amount else 0,
                "buyer_name": r.buyer_name, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/invoice")
def create_invoice(
    payment_id: int = 0,
    invoice_type: str = "normal",
    amount: float = 0,
    buyer_name: str = "",
    buyer_tax_no: str = "",
    db: Session = Depends(get_db),
):
    """生成发票"""
    import uuid
    invoice_no = f"FP-{uuid.uuid4().hex[:10].upper()}"

    inv = Invoice(
        invoice_no=invoice_no,
        payment_id=payment_id if payment_id else None,
        invoice_type=invoice_type,
        amount=amount,
        buyer_name=buyer_name,
        buyer_tax_no=buyer_tax_no,
        status=1,
    )
    db.add(inv)
    db.commit()

    return {"code": 200, "data": {"invoice_id": inv.id, "invoice_no": invoice_no}}
