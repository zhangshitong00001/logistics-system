from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.reconciliation import Settlement
from datetime import datetime, timezone

router = APIRouter(prefix="/api/v1/settlement", tags=["资金结算管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """结算仪表盘"""
    pending_amount = db.query(func.sum(Settlement.settle_amount)).filter(
        Settlement.status == 0, Settlement.deleted == 0,
    ).scalar() or 0

    this_month = db.query(func.sum(Settlement.settle_amount)).filter(
        func.date_trunc('month', Settlement.create_time) == func.date_trunc('month', func.now()),
        Settlement.deleted == 0,
    ).scalar() or 0

    payable = db.query(func.sum(Settlement.settle_amount)).filter(
        Settlement.direction == 'payable', Settlement.deleted == 0,
    ).scalar() or 0

    receivable = db.query(func.sum(Settlement.settle_amount)).filter(
        Settlement.direction == 'receivable', Settlement.deleted == 0,
    ).scalar() or 0

    return {
        "code": 200,
        "data": {
            "pending_amount": float(pending_amount),
            "this_month_amount": float(this_month),
            "payable_amount": float(payable),
            "receivable_amount": float(receivable),
        }
    }


@router.get("/order")
def get_orders(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """结算单列表"""
    q = db.query(Settlement).filter(Settlement.deleted == 0)
    if status >= 0:
        q = q.filter(Settlement.status == status)

    total = q.count()
    records = q.order_by(Settlement.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "settle_no": r.settle_no, "partner": r.partner,
                "settle_amount": float(r.settle_amount) if r.settle_amount else 0,
                "direction": r.direction, "status": r.status,
                "submitter": r.submitter,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/order")
def create_order(
    recon_id: int = 0,
    partner: str = "",
    settle_amount: float = 0,
    direction: str = "payable",
    submitter: str = "",
    db: Session = Depends(get_db),
):
    """生成结算单"""
    import uuid
    settle_no = f"JS-{uuid.uuid4().hex[:8].upper()}"

    settlement = Settlement(
        settle_no=settle_no,
        recon_id=recon_id if recon_id else None,
        partner=partner,
        settle_amount=settle_amount,
        direction=direction,
        status=0,
        submitter=submitter,
    )
    db.add(settlement)
    db.commit()

    return {"code": 200, "data": {"settle_id": settlement.id, "settle_no": settle_no}}


@router.put("/order/{settle_id}/submit-audit")
def submit_audit(settle_id: int, db: Session = Depends(get_db)):
    """提交审核"""
    s = db.query(Settlement).filter(
        Settlement.id == settle_id, Settlement.deleted == 0,
    ).first()
    if not s:
        return {"code": 404, "message": "结算单不存在"}
    s.status = 1
    db.commit()
    return {"code": 200, "message": "已提交审核"}


@router.put("/order/{settle_id}/audit")
def audit(settle_id: int, status: int = 2, audit_comment: str = "", auditor: str = "", db: Session = Depends(get_db)):
    """审核结算单"""
    s = db.query(Settlement).filter(
        Settlement.id == settle_id, Settlement.deleted == 0,
    ).first()
    if not s:
        return {"code": 404, "message": "结算单不存在"}
    s.status = status
    s.audit_comment = audit_comment
    s.auditor = auditor
    s.audit_time = datetime.now(timezone.utc)
    db.commit()
    return {"code": 200, "message": "审核完成"}
