from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.sign_receipt import SignReceipt
from app.models.delivery import DeliveryTask

router = APIRouter(prefix="/api/v1/sign", tags=["签收入库管理"])


@router.get("/package/{package_no}")
def get_package_info(package_no: str, db: Session = Depends(get_db)):
    """查询包裹信息"""
    receipt = db.query(SignReceipt).filter(
        SignReceipt.package_no == package_no, SignReceipt.deleted == 0,
    ).first()

    if not receipt:
        return {"code": 200, "data": {"package_no": package_no, "found": False}}

    return {
        "code": 200,
        "data": {
            "package_no": receipt.package_no,
            "sign_result": receipt.sign_result,
            "signer": receipt.signer,
            "sign_time": str(receipt.sign_time) if receipt.sign_time else None,
            "inbound_status": receipt.inbound_status,
            "found": True,
        }
    }


@router.post("")
def submit_sign(
    package_no: str = "",
    delivery_task_id: int = 0,
    pickup_point_id: int = 0,
    sign_result: str = "normal",
    signer: str = "",
    remark: str = "",
    db: Session = Depends(get_db),
):
    """提交签收"""
    import uuid
    receipt_no = f"SR-{uuid.uuid4().hex[:8].upper()}"

    from datetime import datetime, timezone
    receipt = SignReceipt(
        receipt_no=receipt_no,
        package_no=package_no,
        delivery_task_id=delivery_task_id if delivery_task_id else None,
        pickup_point_id=pickup_point_id if pickup_point_id else None,
        sign_result=sign_result,
        signer=signer,
        sign_time=datetime.now(timezone.utc),
        remark=remark,
        inbound_status=0,
    )
    db.add(receipt)

    # Update delivery task status
    if delivery_task_id:
        task = db.query(DeliveryTask).filter(
            DeliveryTask.id == delivery_task_id, DeliveryTask.deleted == 0,
        ).first()
        if task:
            task.status = 2

    db.commit()
    return {"code": 200, "data": {"sign_id": receipt.id, "receipt_no": receipt_no}}


@router.put("/{sign_id}/inbound")
def confirm_inbound(sign_id: int, db: Session = Depends(get_db)):
    """确认入库"""
    receipt = db.query(SignReceipt).filter(
        SignReceipt.id == sign_id, SignReceipt.deleted == 0,
    ).first()
    if not receipt:
        return {"code": 404, "message": "签收记录不存在"}

    receipt.inbound_status = 1
    db.commit()
    return {"code": 200, "message": "入库确认成功"}


@router.get("/records")
def get_records(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    sign_result: str = "",
    inbound_status: int = -1,
    db: Session = Depends(get_db),
):
    """签收记录列表"""
    q = db.query(SignReceipt).filter(SignReceipt.deleted == 0)
    if sign_result:
        q = q.filter(SignReceipt.sign_result == sign_result)
    if inbound_status >= 0:
        q = q.filter(SignReceipt.inbound_status == inbound_status)

    total = q.count()
    records = q.order_by(SignReceipt.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "receipt_no": r.receipt_no, "package_no": r.package_no,
                "sign_result": r.sign_result, "signer": r.signer,
                "sign_time": str(r.sign_time) if r.sign_time else None,
                "inbound_status": r.inbound_status,
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }
