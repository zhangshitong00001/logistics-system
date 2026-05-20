from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.customs_declaration import CustomsDeclaration

router = APIRouter(prefix="/api/v1/customs", tags=["报关清关管理"])


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """报关仪表盘"""
    total = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.deleted == 0,
    ).scalar() or 0

    pending = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.status == 0, CustomsDeclaration.deleted == 0,
    ).scalar() or 0

    reviewing = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.status == 1, CustomsDeclaration.deleted == 0,
    ).scalar() or 0

    approved = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.status == 2, CustomsDeclaration.deleted == 0,
    ).scalar() or 0

    rejected = db.query(func.count(CustomsDeclaration.id)).filter(
        CustomsDeclaration.status == 3, CustomsDeclaration.deleted == 0,
    ).scalar() or 0

    return {
        "code": 200,
        "data": {
            "total": total, "pending": pending,
            "reviewing": reviewing, "approved": approved, "rejected": rejected,
        }
    }


@router.get("/declaration")
def get_declarations(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    status: int = -1,
    db: Session = Depends(get_db),
):
    """报关单列表"""
    q = db.query(CustomsDeclaration).filter(CustomsDeclaration.deleted == 0)
    if status >= 0:
        q = q.filter(CustomsDeclaration.status == status)

    total = q.count()
    records = q.order_by(CustomsDeclaration.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id, "declaration_no": r.declaration_no,
                "batch_no": r.batch_no,
                "total_value": float(r.total_value) if r.total_value else 0,
                "currency": r.currency, "customs_office": r.customs_office,
                "declaration_type": r.declaration_type, "status": r.status,
                "submitter": r.submitter,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total, "page": page, "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/declaration")
def submit_declaration(
    batch_no: str = "",
    total_value: float = 0,
    currency: str = "USD",
    customs_office: str = "霍尔果斯口岸",
    declaration_type: str = "export",
    submitter: str = "",
    file_ids: str = "",
    db: Session = Depends(get_db),
):
    """提交报关"""
    import uuid
    decl_no = f"BG-{uuid.uuid4().hex[:10].upper()}"

    decl = CustomsDeclaration(
        declaration_no=decl_no,
        batch_no=batch_no,
        total_value=total_value,
        currency=currency,
        customs_office=customs_office,
        declaration_type=declaration_type,
        status=1,  # 审核中
        submitter=submitter,
        file_ids=file_ids,
    )
    db.add(decl)
    db.commit()

    return {"code": 200, "data": {"declaration_id": decl.id, "declaration_no": decl_no}}


@router.get("/declaration/{decl_id}")
def get_declaration_detail(decl_id: int, db: Session = Depends(get_db)):
    """报关单详情"""
    decl = db.query(CustomsDeclaration).filter(
        CustomsDeclaration.id == decl_id, CustomsDeclaration.deleted == 0,
    ).first()
    if not decl:
        return {"code": 404, "message": "报关单不存在"}

    return {
        "code": 200,
        "data": {
            "id": decl.id, "declaration_no": decl.declaration_no,
            "batch_no": decl.batch_no,
            "total_value": float(decl.total_value) if decl.total_value else 0,
            "currency": decl.currency, "customs_office": decl.customs_office,
            "declaration_type": decl.declaration_type, "status": decl.status,
            "review_comment": decl.review_comment, "submitter": decl.submitter,
            "create_time": str(decl.create_time),
            "review_time": str(decl.review_time) if decl.review_time else None,
        }
    }


@router.put("/declaration/{decl_id}/review")
def review_declaration(
    decl_id: int,
    status: int = 2,
    review_comment: str = "",
    db: Session = Depends(get_db),
):
    """审核报关单"""
    decl = db.query(CustomsDeclaration).filter(
        CustomsDeclaration.id == decl_id, CustomsDeclaration.deleted == 0,
    ).first()
    if not decl:
        return {"code": 404, "message": "报关单不存在"}

    decl.status = status
    decl.review_comment = review_comment
    from datetime import datetime, timezone
    decl.review_time = datetime.now(timezone.utc)
    db.commit()

    return {"code": 200, "message": "审核完成"}
