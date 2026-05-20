from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db
from app.models.file_record import FileRecord

router = APIRouter(prefix="/api/v1/files", tags=["文件生成管理"])


@router.get("")
def get_files(
    page: int = Query(1, ge=1),
    size: int = Query(20, ge=1, le=100),
    file_type: str = "",
    batch_no: str = "",
    db: Session = Depends(get_db),
):
    """文件列表"""
    q = db.query(FileRecord).filter(FileRecord.deleted == 0)
    if file_type:
        q = q.filter(FileRecord.file_type == file_type)
    if batch_no:
        q = q.filter(FileRecord.batch_no == batch_no)

    total = q.count()
    records = q.order_by(FileRecord.create_time.desc())\
                .offset((page - 1) * size).limit(size).all()

    return {
        "code": 200,
        "data": {
            "records": [{
                "id": r.id,
                "file_no": r.file_no,
                "file_name": r.file_name,
                "file_type": r.file_type,
                "version": r.version,
                "batch_no": r.batch_no,
                "file_size": r.file_size,
                "status": r.status,
                "create_time": str(r.create_time),
            } for r in records],
            "total": total,
            "page": page,
            "size": size,
            "pages": (total + size - 1) // size,
        }
    }


@router.post("/loading-list")
def generate_loading_list(
    batch_no: str = "",
    vehicle_id: int = 0,
    contents: list = [],
    db: Session = Depends(get_db),
):
    """生成装车文件"""
    import uuid
    file_no = f"FL-{uuid.uuid4().hex[:10].upper()}"

    rec = FileRecord(
        file_no=file_no,
        file_name=f"装车清单_{batch_no}",
        file_type="loading_list",
        version="v1.0",
        batch_no=batch_no,
        status=1,
    )
    db.add(rec)
    db.commit()

    return {"code": 200, "data": {"file_id": rec.id, "file_no": file_no}}


@router.post("/customs-docs")
def generate_customs_docs(
    batch_no: str = "",
    doc_types: list = [],
    db: Session = Depends(get_db),
):
    """生成报关文件"""
    import uuid
    results = []

    type_names = {
        "invoice": "商业发票",
        "packing_list": "装箱单",
        "declaration": "报关单",
        "certificate": "原产地证明",
    }

    for dt in doc_types:
        name = type_names.get(dt, dt)
        file_no = f"CD-{uuid.uuid4().hex[:10].upper()}"
        rec = FileRecord(
            file_no=file_no,
            file_name=f"{name}_{batch_no}",
            file_type=dt,
            version="v1.0",
            batch_no=batch_no,
            status=1,
        )
        db.add(rec)
        db.flush()
        results.append({"file_id": rec.id, "file_no": file_no})

    db.commit()
    return {"code": 200, "data": {"file_ids": results}}
