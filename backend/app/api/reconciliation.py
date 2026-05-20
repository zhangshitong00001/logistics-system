from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.reconciliation import Reconciliation, Settlement

router = APIRouter(prefix="/api/v1/reconciliation", tags=["对账管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """对账仪表盘"""
    pending = db.query(func.count(Reconciliation.id)).filter(
        Reconciliation.status == 0, Reconciliation.deleted == 0,
    ).scalar() or 0

    in_progress = db.query(func.count(Reconciliation.id)).filter(
        Reconciliation.status == 1, Reconciliation.deleted == 0,
    ).scalar() or 0

    completed = db.query(func.count(Reconciliation.id)).filter(
        Reconciliation.status == 2, Reconciliation.deleted == 0,
    ).scalar() or 0

    diff = db.query(func.count(Reconciliation.id)).filter(
        Reconciliation.status == 3, Reconciliation.deleted == 0,
    ).scalar() or 0

    total_diff = db.query(func.sum(Reconciliation.diff_amount)).filter(
        Reconciliation.status == 3, Reconciliation.deleted == 0,
    ).scalar() or 0

    return {
        "code": 200,
        "data": {
            "pending": pending, "in_progress": in_progress,
            "completed": completed, "diff_pending": diff,
            "total_diff_amount": float(total_diff),
        }
    }


@router.get("/task")
def get_tasks(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """对账任务列表"""
    q = db.query(Reconciliation).filter(Reconciliation.deleted == 0)
    if status >= 0:
        q = q.filter(Reconciliation.status == status)

    total = q.count()
    records = q.order_by(Reconciliation.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "recon_no": r.recon_no, "partner": r.partner,
                "cycle_start": str(r.cycle_start), "cycle_end": str(r.cycle_end),
                "order_amount": float(r.order_amount) if r.order_amount else 0,
                "logistics_fee": float(r.logistics_fee) if r.logistics_fee else 0,
                "diff_amount": float(r.diff_amount) if r.diff_amount else 0,
                "diff_count": r.diff_count, "status": r.status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/task")
def create_task(
    partner: str = "",
    cycle_start: str = "",
    cycle_end: str = "",
    order_amount: float = 0,
    logistics_fee: float = 0,
    db: Session = Depends(get_db),
):
    """新建对账任务"""
    import uuid
    from datetime import date
    recon_no = f"DZ-{uuid.uuid4().hex[:8].upper()}"

    def parse_date(s):
        from datetime import datetime
        return datetime.strptime(s, "%Y-%m-%d").date() if s else None

    recon = Reconciliation(
        recon_no=recon_no, partner=partner,
        cycle_start=parse_date(cycle_start), cycle_end=parse_date(cycle_end),
        order_amount=order_amount, logistics_fee=logistics_fee,
        diff_amount=abs(order_amount - logistics_fee),
        diff_count=1 if order_amount != logistics_fee else 0,
        status=1 if order_amount != logistics_fee else 2,
    )
    db.add(recon)
    db.commit()

    return {"code": 200, "data": {"recon_id": recon.id, "recon_no": recon_no}}


@router.put("/task/{recon_id}/resolve-diff")
def resolve_diff(recon_id: int, diff_reason: str = "", handle_result: str = "", db: Session = Depends(get_db)):
    """处理对账差异"""
    recon = db.query(Reconciliation).filter(
        Reconciliation.id == recon_id, Reconciliation.deleted == 0,
    ).first()
    if not recon:
        return {"code": 404, "message": "对账任务不存在"}
    recon.status = 2
    recon.diff_count = 0
    recon.diff_amount = 0
    db.commit()
    return {"code": 200, "message": "差异已处理"}
