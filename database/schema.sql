--
-- PostgreSQL database dump
--

\restrict m1gxDdElthgkOYzZgw6edSIauFeIAk8YjXpQiP0m0gun3JGimjCyGH4OuFN2PFh

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_record (
    id integer NOT NULL,
    batch_no character varying(64),
    alert_type character varying(32) NOT NULL,
    severity character varying(16),
    content text,
    status integer,
    handled_by character varying(64),
    handle_result text,
    handle_time timestamp without time zone,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN alert_record.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.batch_no IS '关联批次号';


--
-- Name: COLUMN alert_record.alert_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.alert_type IS '预警类型';


--
-- Name: COLUMN alert_record.severity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.severity IS '严重级别';


--
-- Name: COLUMN alert_record.content; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.content IS '预警内容';


--
-- Name: COLUMN alert_record.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.status IS '状态:0待处理1处理中2已处理3已关闭';


--
-- Name: COLUMN alert_record.handled_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.handled_by IS '处理人';


--
-- Name: COLUMN alert_record.handle_result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.handle_result IS '处理结果';


--
-- Name: COLUMN alert_record.handle_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_record.handle_time IS '处理时间';


--
-- Name: alert_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_record_id_seq OWNED BY public.alert_record.id;


--
-- Name: alert_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alert_rule (
    id integer NOT NULL,
    rule_name character varying(128) NOT NULL,
    alert_type character varying(32) NOT NULL,
    severity character varying(16),
    trigger_condition text,
    threshold_value character varying(64),
    notify_method character varying(64),
    notify_role_id integer,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN alert_rule.rule_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.rule_name IS '规则名称';


--
-- Name: COLUMN alert_rule.alert_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.alert_type IS '预警类型:delay/customs/transport/sign/reconciliation';


--
-- Name: COLUMN alert_rule.severity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.severity IS '严重级别:low/medium/high/critical';


--
-- Name: COLUMN alert_rule.trigger_condition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.trigger_condition IS '触发条件';


--
-- Name: COLUMN alert_rule.threshold_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.threshold_value IS '阈值';


--
-- Name: COLUMN alert_rule.notify_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.notify_method IS '通知方式';


--
-- Name: COLUMN alert_rule.notify_role_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.notify_role_id IS '通知角色ID';


--
-- Name: COLUMN alert_rule.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.alert_rule.status IS '状态:1启用0禁用';


--
-- Name: alert_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alert_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alert_rule_id_seq OWNED BY public.alert_rule.id;


--
-- Name: billing_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_rule (
    id integer NOT NULL,
    rule_name character varying(128) NOT NULL,
    fee_type character varying(16) NOT NULL,
    charge_method character varying(16),
    base_rate numeric(18,4),
    rate_unit character varying(16),
    currency character varying(8),
    tier_config text,
    applicable_condition text,
    priority integer,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN billing_rule.rule_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.rule_name IS '规则名称';


--
-- Name: COLUMN billing_rule.fee_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.fee_type IS '费用类型:transport/storage/packaging/surcharge';


--
-- Name: COLUMN billing_rule.charge_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.charge_method IS '计费方式:weight/volume/fixed';


--
-- Name: COLUMN billing_rule.base_rate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.base_rate IS '基础费率';


--
-- Name: COLUMN billing_rule.rate_unit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.rate_unit IS '费率单位';


--
-- Name: COLUMN billing_rule.currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.currency IS '币种';


--
-- Name: COLUMN billing_rule.tier_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.tier_config IS '阶梯配置(JSON)';


--
-- Name: COLUMN billing_rule.applicable_condition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.applicable_condition IS '适用条件';


--
-- Name: COLUMN billing_rule.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.priority IS '优先级';


--
-- Name: COLUMN billing_rule.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.billing_rule.status IS '状态:1启用0禁用';


--
-- Name: billing_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_rule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_rule_id_seq OWNED BY public.billing_rule.id;


--
-- Name: customs_declaration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customs_declaration (
    id integer NOT NULL,
    declaration_no character varying(64) NOT NULL,
    batch_no character varying(64) NOT NULL,
    sku_info text,
    total_value numeric(18,2),
    currency character varying(8),
    customs_office character varying(128),
    declaration_type character varying(16),
    status integer,
    review_comment text,
    submitter character varying(64),
    review_time timestamp without time zone,
    file_ids text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN customs_declaration.declaration_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.declaration_no IS '报关单号';


--
-- Name: COLUMN customs_declaration.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.batch_no IS '批次号';


--
-- Name: COLUMN customs_declaration.sku_info; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.sku_info IS '货物信息(JSON)';


--
-- Name: COLUMN customs_declaration.total_value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.total_value IS '总金额';


--
-- Name: COLUMN customs_declaration.currency; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.currency IS '币种';


--
-- Name: COLUMN customs_declaration.customs_office; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.customs_office IS '报关口岸';


--
-- Name: COLUMN customs_declaration.declaration_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.declaration_type IS '类型:export出口/import进口';


--
-- Name: COLUMN customs_declaration.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.status IS '状态:0待提交1审核中2已通过3已驳回';


--
-- Name: COLUMN customs_declaration.review_comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.review_comment IS '审核意见';


--
-- Name: COLUMN customs_declaration.submitter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.submitter IS '提交人';


--
-- Name: COLUMN customs_declaration.review_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.review_time IS '审核时间';


--
-- Name: COLUMN customs_declaration.file_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.customs_declaration.file_ids IS '附件文件ID(JSON数组)';


--
-- Name: customs_declaration_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customs_declaration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customs_declaration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customs_declaration_id_seq OWNED BY public.customs_declaration.id;


--
-- Name: delivery_task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_task (
    id integer NOT NULL,
    task_no character varying(64) NOT NULL,
    pickup_point_id integer,
    package_count integer,
    batch_no character varying(64),
    delivery_person character varying(64),
    delivery_phone character varying(20),
    status integer,
    remark text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN delivery_task.task_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.task_no IS '配送单号';


--
-- Name: COLUMN delivery_task.pickup_point_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.pickup_point_id IS '收件点ID';


--
-- Name: COLUMN delivery_task.package_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.package_count IS '包裹数';


--
-- Name: COLUMN delivery_task.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.batch_no IS '批次号';


--
-- Name: COLUMN delivery_task.delivery_person; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.delivery_person IS '配送员';


--
-- Name: COLUMN delivery_task.delivery_phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.delivery_phone IS '配送员电话';


--
-- Name: COLUMN delivery_task.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.status IS '状态:0待配送1配送中2已签收3异常';


--
-- Name: COLUMN delivery_task.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.delivery_task.remark IS '备注';


--
-- Name: delivery_task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delivery_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delivery_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delivery_task_id_seq OWNED BY public.delivery_task.id;


--
-- Name: file_record; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_record (
    id integer NOT NULL,
    file_no character varying(64) NOT NULL,
    file_name character varying(256) NOT NULL,
    file_type character varying(32) NOT NULL,
    version character varying(16),
    batch_no character varying(64),
    file_path character varying(512),
    file_size integer,
    status integer,
    creator character varying(64),
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN file_record.file_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.file_no IS '文件编号';


--
-- Name: COLUMN file_record.file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.file_name IS '文件名';


--
-- Name: COLUMN file_record.file_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.file_type IS '文件类型:loading_list/invoice/packing_list/declaration/certificate';


--
-- Name: COLUMN file_record.version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.version IS '版本号';


--
-- Name: COLUMN file_record.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.batch_no IS '关联批次号';


--
-- Name: COLUMN file_record.file_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.file_path IS '文件路径';


--
-- Name: COLUMN file_record.file_size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.file_size IS '文件大小(bytes)';


--
-- Name: COLUMN file_record.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.status IS '状态:0待生成1已生成2已作废';


--
-- Name: COLUMN file_record.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_record.creator IS '创建人';


--
-- Name: file_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_record_id_seq OWNED BY public.file_record.id;


--
-- Name: file_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_template (
    id integer NOT NULL,
    template_name character varying(128) NOT NULL,
    template_type character varying(32) NOT NULL,
    file_path character varying(512),
    description text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN file_template.template_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_template.template_name IS '模板名称';


--
-- Name: COLUMN file_template.template_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_template.template_type IS '模板类型';


--
-- Name: COLUMN file_template.file_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_template.file_path IS '模板文件路径';


--
-- Name: COLUMN file_template.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.file_template.description IS '描述';


--
-- Name: file_template_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_template_id_seq OWNED BY public.file_template.id;


--
-- Name: invoice; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice (
    id integer NOT NULL,
    invoice_no character varying(64) NOT NULL,
    payment_id integer,
    invoice_type character varying(16),
    amount numeric(18,2),
    buyer_name character varying(128),
    buyer_tax_no character varying(32),
    invoice_file_path character varying(512),
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN invoice.invoice_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.invoice_no IS '发票号';


--
-- Name: COLUMN invoice.payment_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.payment_id IS '支付ID';


--
-- Name: COLUMN invoice.invoice_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.invoice_type IS '发票类型:vat增值税/normal普通';


--
-- Name: COLUMN invoice.amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.amount IS '金额';


--
-- Name: COLUMN invoice.buyer_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.buyer_name IS '购方名称';


--
-- Name: COLUMN invoice.buyer_tax_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.buyer_tax_no IS '购方税号';


--
-- Name: COLUMN invoice.invoice_file_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.invoice_file_path IS '发票文件路径';


--
-- Name: COLUMN invoice.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.invoice.status IS '状态:0待开票1已开票2已作废';


--
-- Name: invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_id_seq OWNED BY public.invoice.id;


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id integer NOT NULL,
    payment_no character varying(64) NOT NULL,
    settle_id integer,
    pay_amount numeric(18,2),
    pay_channel character varying(16),
    pay_time timestamp without time zone,
    status integer,
    remark text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN payment.payment_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.payment_no IS '支付单号';


--
-- Name: COLUMN payment.settle_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.settle_id IS '结算单ID';


--
-- Name: COLUMN payment.pay_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.pay_amount IS '支付金额';


--
-- Name: COLUMN payment.pay_channel; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.pay_channel IS '支付渠道:bank/alipay/wechat';


--
-- Name: COLUMN payment.pay_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.pay_time IS '支付时间';


--
-- Name: COLUMN payment.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.status IS '状态:0待支付1支付中2已支付3已退款';


--
-- Name: COLUMN payment.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.payment.remark IS '备注';


--
-- Name: payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_id_seq OWNED BY public.payment.id;


--
-- Name: pickup_point; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pickup_point (
    id integer NOT NULL,
    point_code character varying(64) NOT NULL,
    point_name character varying(128) NOT NULL,
    address character varying(256),
    region character varying(64),
    contact_person character varying(64),
    contact_phone character varying(20),
    coverage_status integer,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN pickup_point.point_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.point_code IS '收件点编号';


--
-- Name: COLUMN pickup_point.point_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.point_name IS '收件点名称';


--
-- Name: COLUMN pickup_point.address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.address IS '地址';


--
-- Name: COLUMN pickup_point.region; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.region IS '区域';


--
-- Name: COLUMN pickup_point.contact_person; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.contact_person IS '联系人';


--
-- Name: COLUMN pickup_point.contact_phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.contact_phone IS '联系电话';


--
-- Name: COLUMN pickup_point.coverage_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.coverage_status IS '覆盖状态:0未覆盖1已覆盖';


--
-- Name: COLUMN pickup_point.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.pickup_point.status IS '状态:1启用0禁用';


--
-- Name: pickup_point_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pickup_point_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pickup_point_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pickup_point_id_seq OWNED BY public.pickup_point.id;


--
-- Name: reconciliation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reconciliation (
    id integer NOT NULL,
    recon_no character varying(64) NOT NULL,
    partner character varying(128),
    cycle_start date,
    cycle_end date,
    order_amount numeric(18,2),
    logistics_fee numeric(18,2),
    diff_amount numeric(18,2),
    diff_count integer,
    status integer,
    operator character varying(64),
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN reconciliation.recon_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.recon_no IS '对账单号';


--
-- Name: COLUMN reconciliation.partner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.partner IS '合作方';


--
-- Name: COLUMN reconciliation.cycle_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.cycle_start IS '周期开始';


--
-- Name: COLUMN reconciliation.cycle_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.cycle_end IS '周期结束';


--
-- Name: COLUMN reconciliation.order_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.order_amount IS '订单金额';


--
-- Name: COLUMN reconciliation.logistics_fee; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.logistics_fee IS '物流费用';


--
-- Name: COLUMN reconciliation.diff_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.diff_amount IS '差异金额';


--
-- Name: COLUMN reconciliation.diff_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.diff_count IS '差异笔数';


--
-- Name: COLUMN reconciliation.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.status IS '状态:0待对账1对账中2已完成3差异待处理';


--
-- Name: COLUMN reconciliation.operator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reconciliation.operator IS '操作人';


--
-- Name: reconciliation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reconciliation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reconciliation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reconciliation_id_seq OWNED BY public.reconciliation.id;


--
-- Name: settlement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settlement (
    id integer NOT NULL,
    settle_no character varying(64) NOT NULL,
    recon_id integer,
    partner character varying(128),
    settle_cycle_start date,
    settle_cycle_end date,
    settle_amount numeric(18,2),
    direction character varying(16),
    status integer,
    audit_comment text,
    submitter character varying(64),
    auditor character varying(64),
    audit_time timestamp without time zone,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN settlement.settle_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.settle_no IS '结算单号';


--
-- Name: COLUMN settlement.recon_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.recon_id IS '对账ID';


--
-- Name: COLUMN settlement.partner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.partner IS '合作方';


--
-- Name: COLUMN settlement.settle_cycle_start; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.settle_cycle_start IS '结算周期开始';


--
-- Name: COLUMN settlement.settle_cycle_end; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.settle_cycle_end IS '结算周期结束';


--
-- Name: COLUMN settlement.settle_amount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.settle_amount IS '结算金额';


--
-- Name: COLUMN settlement.direction; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.direction IS '方向:payable应付/receivable应收';


--
-- Name: COLUMN settlement.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.status IS '状态:0待审核1已通过2已驳回3已完成';


--
-- Name: COLUMN settlement.audit_comment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.audit_comment IS '审核意见';


--
-- Name: COLUMN settlement.submitter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.submitter IS '提交人';


--
-- Name: COLUMN settlement.auditor; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.auditor IS '审核人';


--
-- Name: COLUMN settlement.audit_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.settlement.audit_time IS '审核时间';


--
-- Name: settlement_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settlement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settlement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settlement_id_seq OWNED BY public.settlement.id;


--
-- Name: sign_receipt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sign_receipt (
    id integer NOT NULL,
    receipt_no character varying(64) NOT NULL,
    package_no character varying(64) NOT NULL,
    delivery_task_id integer,
    pickup_point_id integer,
    sign_result character varying(16),
    signer character varying(64),
    sign_time timestamp without time zone,
    signature_image text,
    evidence_image text,
    inbound_status integer,
    remark text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN sign_receipt.receipt_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.receipt_no IS '签收单号';


--
-- Name: COLUMN sign_receipt.package_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.package_no IS '包裹号';


--
-- Name: COLUMN sign_receipt.delivery_task_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.delivery_task_id IS '配送任务ID';


--
-- Name: COLUMN sign_receipt.pickup_point_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.pickup_point_id IS '收件点ID';


--
-- Name: COLUMN sign_receipt.sign_result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.sign_result IS '签收结果:normal正常/damaged破损/shortage短缺/refused拒收';


--
-- Name: COLUMN sign_receipt.signer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.signer IS '签收人';


--
-- Name: COLUMN sign_receipt.sign_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.sign_time IS '签收时间';


--
-- Name: COLUMN sign_receipt.signature_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.signature_image IS '电子签名(Base64)';


--
-- Name: COLUMN sign_receipt.evidence_image; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.evidence_image IS '凭证照片(Base64)';


--
-- Name: COLUMN sign_receipt.inbound_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.inbound_status IS '入库状态:0未入库1已入库';


--
-- Name: COLUMN sign_receipt.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sign_receipt.remark IS '备注';


--
-- Name: sign_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sign_receipt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sign_receipt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sign_receipt_id_seq OWNED BY public.sign_receipt.id;


--
-- Name: sorting_task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sorting_task (
    id integer NOT NULL,
    task_no character varying(64) NOT NULL,
    batch_no character varying(64),
    sku_code character varying(64),
    product_name character varying(256),
    total_qty integer,
    completed_qty integer,
    target_point_id integer,
    priority integer,
    assignee character varying(64),
    status integer,
    remark text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN sorting_task.task_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.task_no IS '任务编号';


--
-- Name: COLUMN sorting_task.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.batch_no IS '批次号';


--
-- Name: COLUMN sorting_task.sku_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.sku_code IS 'SKU编码';


--
-- Name: COLUMN sorting_task.product_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.product_name IS '品名';


--
-- Name: COLUMN sorting_task.total_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.total_qty IS '总数量';


--
-- Name: COLUMN sorting_task.completed_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.completed_qty IS '已完成数量';


--
-- Name: COLUMN sorting_task.target_point_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.target_point_id IS '目标收件点';


--
-- Name: COLUMN sorting_task.priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.priority IS '优先级:0普通1高2紧急';


--
-- Name: COLUMN sorting_task.assignee; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.assignee IS '分装人员';


--
-- Name: COLUMN sorting_task.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.status IS '状态:0待分配1分装中2已完成3异常';


--
-- Name: COLUMN sorting_task.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sorting_task.remark IS '备注';


--
-- Name: sorting_task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sorting_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sorting_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sorting_task_id_seq OWNED BY public.sorting_task.id;


--
-- Name: sys_operation_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_operation_log (
    id integer NOT NULL,
    username character varying(64),
    module character varying(64),
    action character varying(64),
    target character varying(256),
    detail text,
    ip_address character varying(64),
    duration_ms integer,
    status integer,
    create_time timestamp without time zone DEFAULT now()
);


--
-- Name: COLUMN sys_operation_log.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.username IS '操作人';


--
-- Name: COLUMN sys_operation_log.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.module IS '操作模块';


--
-- Name: COLUMN sys_operation_log.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.action IS '操作类型';


--
-- Name: COLUMN sys_operation_log.target; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.target IS '操作对象';


--
-- Name: COLUMN sys_operation_log.detail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.detail IS '详细内容';


--
-- Name: COLUMN sys_operation_log.ip_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.ip_address IS 'IP地址';


--
-- Name: COLUMN sys_operation_log.duration_ms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.duration_ms IS '耗时(毫秒)';


--
-- Name: COLUMN sys_operation_log.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_operation_log.status IS '状态:1成功0失败';


--
-- Name: sys_operation_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_operation_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_operation_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_operation_log_id_seq OWNED BY public.sys_operation_log.id;


--
-- Name: sys_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_permission (
    id integer NOT NULL,
    perm_name character varying(64) NOT NULL,
    perm_code character varying(128) NOT NULL,
    module character varying(64),
    action character varying(32),
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN sys_permission.perm_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.perm_name IS '权限名称';


--
-- Name: COLUMN sys_permission.perm_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.perm_code IS '权限编码';


--
-- Name: COLUMN sys_permission.module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.module IS '所属模块';


--
-- Name: COLUMN sys_permission.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_permission.action IS '操作类型:view/edit/delete';


--
-- Name: sys_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_permission_id_seq OWNED BY public.sys_permission.id;


--
-- Name: sys_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_role (
    id integer NOT NULL,
    role_name character varying(64) NOT NULL,
    role_code character varying(64) NOT NULL,
    description character varying(256),
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN sys_role.role_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.role_name IS '角色名称';


--
-- Name: COLUMN sys_role.role_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.role_code IS '角色编码';


--
-- Name: COLUMN sys_role.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.description IS '描述';


--
-- Name: COLUMN sys_role.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role.status IS '状态:1启用0禁用';


--
-- Name: sys_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_role_id_seq OWNED BY public.sys_role.id;


--
-- Name: sys_role_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_role_permission (
    id integer NOT NULL,
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


--
-- Name: COLUMN sys_role_permission.role_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role_permission.role_id IS '角色ID';


--
-- Name: COLUMN sys_role_permission.permission_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_role_permission.permission_id IS '权限ID';


--
-- Name: sys_role_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_role_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_role_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_role_permission_id_seq OWNED BY public.sys_role_permission.id;


--
-- Name: sys_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sys_user (
    id integer NOT NULL,
    username character varying(64) NOT NULL,
    password_hash character varying(256) NOT NULL,
    real_name character varying(64),
    phone character varying(20),
    email character varying(128),
    role_id integer,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN sys_user.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.username IS '用户名';


--
-- Name: COLUMN sys_user.password_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.password_hash IS '密码哈希';


--
-- Name: COLUMN sys_user.real_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.real_name IS '真实姓名';


--
-- Name: COLUMN sys_user.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.phone IS '手机号';


--
-- Name: COLUMN sys_user.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.email IS '邮箱';


--
-- Name: COLUMN sys_user.role_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.role_id IS '角色ID';


--
-- Name: COLUMN sys_user.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sys_user.status IS '状态:1启用0禁用';


--
-- Name: sys_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sys_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sys_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sys_user_id_seq OWNED BY public.sys_user.id;


--
-- Name: tracking_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracking_log (
    id integer NOT NULL,
    package_no character varying(64) NOT NULL,
    node_name character varying(64),
    node_order integer,
    operator character varying(64),
    location character varying(128),
    description text,
    status integer,
    operate_time timestamp without time zone,
    create_time timestamp without time zone DEFAULT now()
);


--
-- Name: COLUMN tracking_log.package_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.package_no IS '包裹号';


--
-- Name: COLUMN tracking_log.node_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.node_name IS '节点名称';


--
-- Name: COLUMN tracking_log.node_order; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.node_order IS '节点顺序';


--
-- Name: COLUMN tracking_log.operator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.operator IS '操作人';


--
-- Name: COLUMN tracking_log.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.location IS '地点';


--
-- Name: COLUMN tracking_log.description; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.description IS '描述';


--
-- Name: COLUMN tracking_log.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.status IS '状态:0进行中1已完成';


--
-- Name: COLUMN tracking_log.operate_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_log.operate_time IS '操作时间';


--
-- Name: tracking_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tracking_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracking_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tracking_log_id_seq OWNED BY public.tracking_log.id;


--
-- Name: tracking_package; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracking_package (
    id integer NOT NULL,
    package_no character varying(64) NOT NULL,
    order_no character varying(64),
    batch_no character varying(64),
    product_name character varying(256),
    sku_code character varying(64),
    qty integer,
    weight_kg double precision,
    sender character varying(128),
    receiver character varying(128),
    receiver_phone character varying(20),
    receiver_address character varying(256),
    current_node character varying(64),
    current_status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN tracking_package.package_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.package_no IS '包裹号';


--
-- Name: COLUMN tracking_package.order_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.order_no IS '订单号';


--
-- Name: COLUMN tracking_package.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.batch_no IS '批次号';


--
-- Name: COLUMN tracking_package.product_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.product_name IS '品名';


--
-- Name: COLUMN tracking_package.sku_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.sku_code IS 'SKU编码';


--
-- Name: COLUMN tracking_package.qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.qty IS '数量';


--
-- Name: COLUMN tracking_package.weight_kg; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.weight_kg IS '重量(kg)';


--
-- Name: COLUMN tracking_package.sender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.sender IS '发件方';


--
-- Name: COLUMN tracking_package.receiver; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.receiver IS '收件方';


--
-- Name: COLUMN tracking_package.receiver_phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.receiver_phone IS '收件人电话';


--
-- Name: COLUMN tracking_package.receiver_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.receiver_address IS '收件地址';


--
-- Name: COLUMN tracking_package.current_node; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.current_node IS '当前节点';


--
-- Name: COLUMN tracking_package.current_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tracking_package.current_status IS '状态:0待集货1运输中2报关中3清关中4配送中5已签收';


--
-- Name: tracking_package_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tracking_package_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracking_package_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tracking_package_id_seq OWNED BY public.tracking_package.id;


--
-- Name: transport_task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_task (
    id integer NOT NULL,
    task_no character varying(64) NOT NULL,
    vehicle_id integer,
    route_from character varying(128),
    route_to character varying(128),
    departure_time timestamp without time zone,
    estimated_arrival timestamp without time zone,
    actual_arrival timestamp without time zone,
    batch_no character varying(64),
    driver_name character varying(64),
    driver_phone character varying(20),
    status integer,
    remark text,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN transport_task.task_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.task_no IS '任务编号';


--
-- Name: COLUMN transport_task.vehicle_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.vehicle_id IS '车辆ID';


--
-- Name: COLUMN transport_task.route_from; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.route_from IS '出发地';


--
-- Name: COLUMN transport_task.route_to; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.route_to IS '目的地';


--
-- Name: COLUMN transport_task.departure_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.departure_time IS '出发时间';


--
-- Name: COLUMN transport_task.estimated_arrival; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.estimated_arrival IS '预计到达';


--
-- Name: COLUMN transport_task.actual_arrival; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.actual_arrival IS '实际到达';


--
-- Name: COLUMN transport_task.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.batch_no IS '关联批次号';


--
-- Name: COLUMN transport_task.driver_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.driver_name IS '司机';


--
-- Name: COLUMN transport_task.driver_phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.driver_phone IS '司机电话';


--
-- Name: COLUMN transport_task.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.status IS '状态:0待发车1运输中2已到达3已完成4异常';


--
-- Name: COLUMN transport_task.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_task.remark IS '备注';


--
-- Name: transport_task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transport_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transport_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transport_task_id_seq OWNED BY public.transport_task.id;


--
-- Name: transport_vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_vehicle (
    id integer NOT NULL,
    plate_no character varying(32) NOT NULL,
    vehicle_type character varying(32),
    driver_name character varying(64),
    driver_phone character varying(20),
    max_weight double precision,
    max_volume double precision,
    longitude double precision,
    latitude double precision,
    speed double precision,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN transport_vehicle.plate_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.plate_no IS '车牌号';


--
-- Name: COLUMN transport_vehicle.vehicle_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.vehicle_type IS '车型';


--
-- Name: COLUMN transport_vehicle.driver_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.driver_name IS '司机姓名';


--
-- Name: COLUMN transport_vehicle.driver_phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.driver_phone IS '司机电话';


--
-- Name: COLUMN transport_vehicle.max_weight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.max_weight IS '最大载重(kg)';


--
-- Name: COLUMN transport_vehicle.max_volume; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.max_volume IS '最大容积(m³)';


--
-- Name: COLUMN transport_vehicle.longitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.longitude IS '经度';


--
-- Name: COLUMN transport_vehicle.latitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.latitude IS '纬度';


--
-- Name: COLUMN transport_vehicle.speed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.speed IS '速度(km/h)';


--
-- Name: COLUMN transport_vehicle.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.transport_vehicle.status IS '状态:1空闲2运输中3维修';


--
-- Name: transport_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transport_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transport_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transport_vehicle_id_seq OWNED BY public.transport_vehicle.id;


--
-- Name: warehouse_inventory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouse_inventory (
    id integer NOT NULL,
    sku_code character varying(64) NOT NULL,
    product_name character varying(256) NOT NULL,
    category character varying(64),
    weight_kg double precision,
    total_qty integer,
    available_qty integer,
    locked_qty integer,
    location character varying(64),
    owner character varying(128),
    alert_low_qty integer,
    alert_high_qty integer,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN warehouse_inventory.sku_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.sku_code IS 'SKU编码';


--
-- Name: COLUMN warehouse_inventory.product_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.product_name IS '品名';


--
-- Name: COLUMN warehouse_inventory.category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.category IS '品类';


--
-- Name: COLUMN warehouse_inventory.weight_kg; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.weight_kg IS '单位重量(kg)';


--
-- Name: COLUMN warehouse_inventory.total_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.total_qty IS '总库存';


--
-- Name: COLUMN warehouse_inventory.available_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.available_qty IS '可用数量';


--
-- Name: COLUMN warehouse_inventory.locked_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.locked_qty IS '锁定数量';


--
-- Name: COLUMN warehouse_inventory.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.location IS '库位';


--
-- Name: COLUMN warehouse_inventory.owner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.owner IS '货主';


--
-- Name: COLUMN warehouse_inventory.alert_low_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.alert_low_qty IS '缺货预警阈值';


--
-- Name: COLUMN warehouse_inventory.alert_high_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.alert_high_qty IS '溢货预警阈值';


--
-- Name: COLUMN warehouse_inventory.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_inventory.status IS '状态:1正常0停用';


--
-- Name: warehouse_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.warehouse_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: warehouse_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.warehouse_inventory_id_seq OWNED BY public.warehouse_inventory.id;


--
-- Name: warehouse_receipt; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouse_receipt (
    id integer NOT NULL,
    receipt_no character varying(64) NOT NULL,
    batch_no character varying(64) NOT NULL,
    sku_code character varying(64) NOT NULL,
    product_name character varying(256),
    qty integer NOT NULL,
    weight_kg double precision,
    owner character varying(128),
    location character varying(64),
    operator character varying(64),
    receipt_date timestamp without time zone,
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN warehouse_receipt.receipt_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.receipt_no IS '收货单号';


--
-- Name: COLUMN warehouse_receipt.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.batch_no IS '批次号';


--
-- Name: COLUMN warehouse_receipt.sku_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.sku_code IS 'SKU编码';


--
-- Name: COLUMN warehouse_receipt.product_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.product_name IS '品名';


--
-- Name: COLUMN warehouse_receipt.qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.qty IS '数量';


--
-- Name: COLUMN warehouse_receipt.weight_kg; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.weight_kg IS '重量(kg)';


--
-- Name: COLUMN warehouse_receipt.owner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.owner IS '货主';


--
-- Name: COLUMN warehouse_receipt.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.location IS '存放库位';


--
-- Name: COLUMN warehouse_receipt.operator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.operator IS '操作人';


--
-- Name: COLUMN warehouse_receipt.receipt_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.receipt_date IS '收货日期';


--
-- Name: COLUMN warehouse_receipt.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_receipt.status IS '状态:0待确认1已确认';


--
-- Name: warehouse_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.warehouse_receipt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: warehouse_receipt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.warehouse_receipt_id_seq OWNED BY public.warehouse_receipt.id;


--
-- Name: warehouse_sorting_task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warehouse_sorting_task (
    id integer NOT NULL,
    task_no character varying(64) NOT NULL,
    batch_no character varying(64),
    sku_code character varying(64),
    product_name character varying(256),
    total_qty integer,
    sorted_qty integer,
    location character varying(64),
    assignee character varying(64),
    status integer,
    create_time timestamp without time zone DEFAULT now(),
    update_time timestamp without time zone DEFAULT now(),
    deleted integer
);


--
-- Name: COLUMN warehouse_sorting_task.task_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.task_no IS '任务编号';


--
-- Name: COLUMN warehouse_sorting_task.batch_no; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.batch_no IS '批次号';


--
-- Name: COLUMN warehouse_sorting_task.sku_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.sku_code IS 'SKU编码';


--
-- Name: COLUMN warehouse_sorting_task.product_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.product_name IS '品名';


--
-- Name: COLUMN warehouse_sorting_task.total_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.total_qty IS '总数量';


--
-- Name: COLUMN warehouse_sorting_task.sorted_qty; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.sorted_qty IS '已分拣数量';


--
-- Name: COLUMN warehouse_sorting_task.location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.location IS '库位';


--
-- Name: COLUMN warehouse_sorting_task.assignee; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.assignee IS '分拣员';


--
-- Name: COLUMN warehouse_sorting_task.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.warehouse_sorting_task.status IS '状态:0待分拣1分拣中2已完成3异常';


--
-- Name: warehouse_sorting_task_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.warehouse_sorting_task_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: warehouse_sorting_task_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.warehouse_sorting_task_id_seq OWNED BY public.warehouse_sorting_task.id;


--
-- Name: alert_record id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_record ALTER COLUMN id SET DEFAULT nextval('public.alert_record_id_seq'::regclass);


--
-- Name: alert_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule ALTER COLUMN id SET DEFAULT nextval('public.alert_rule_id_seq'::regclass);


--
-- Name: billing_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_rule ALTER COLUMN id SET DEFAULT nextval('public.billing_rule_id_seq'::regclass);


--
-- Name: customs_declaration id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customs_declaration ALTER COLUMN id SET DEFAULT nextval('public.customs_declaration_id_seq'::regclass);


--
-- Name: delivery_task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_task ALTER COLUMN id SET DEFAULT nextval('public.delivery_task_id_seq'::regclass);


--
-- Name: file_record id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_record ALTER COLUMN id SET DEFAULT nextval('public.file_record_id_seq'::regclass);


--
-- Name: file_template id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_template ALTER COLUMN id SET DEFAULT nextval('public.file_template_id_seq'::regclass);


--
-- Name: invoice id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice ALTER COLUMN id SET DEFAULT nextval('public.invoice_id_seq'::regclass);


--
-- Name: payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment ALTER COLUMN id SET DEFAULT nextval('public.payment_id_seq'::regclass);


--
-- Name: pickup_point id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pickup_point ALTER COLUMN id SET DEFAULT nextval('public.pickup_point_id_seq'::regclass);


--
-- Name: reconciliation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation ALTER COLUMN id SET DEFAULT nextval('public.reconciliation_id_seq'::regclass);


--
-- Name: settlement id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settlement ALTER COLUMN id SET DEFAULT nextval('public.settlement_id_seq'::regclass);


--
-- Name: sign_receipt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sign_receipt ALTER COLUMN id SET DEFAULT nextval('public.sign_receipt_id_seq'::regclass);


--
-- Name: sorting_task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sorting_task ALTER COLUMN id SET DEFAULT nextval('public.sorting_task_id_seq'::regclass);


--
-- Name: sys_operation_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_operation_log ALTER COLUMN id SET DEFAULT nextval('public.sys_operation_log_id_seq'::regclass);


--
-- Name: sys_permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission ALTER COLUMN id SET DEFAULT nextval('public.sys_permission_id_seq'::regclass);


--
-- Name: sys_role id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role ALTER COLUMN id SET DEFAULT nextval('public.sys_role_id_seq'::regclass);


--
-- Name: sys_role_permission id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission ALTER COLUMN id SET DEFAULT nextval('public.sys_role_permission_id_seq'::regclass);


--
-- Name: sys_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user ALTER COLUMN id SET DEFAULT nextval('public.sys_user_id_seq'::regclass);


--
-- Name: tracking_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_log ALTER COLUMN id SET DEFAULT nextval('public.tracking_log_id_seq'::regclass);


--
-- Name: tracking_package id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_package ALTER COLUMN id SET DEFAULT nextval('public.tracking_package_id_seq'::regclass);


--
-- Name: transport_task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_task ALTER COLUMN id SET DEFAULT nextval('public.transport_task_id_seq'::regclass);


--
-- Name: transport_vehicle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_vehicle ALTER COLUMN id SET DEFAULT nextval('public.transport_vehicle_id_seq'::regclass);


--
-- Name: warehouse_inventory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_inventory ALTER COLUMN id SET DEFAULT nextval('public.warehouse_inventory_id_seq'::regclass);


--
-- Name: warehouse_receipt id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_receipt ALTER COLUMN id SET DEFAULT nextval('public.warehouse_receipt_id_seq'::regclass);


--
-- Name: warehouse_sorting_task id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_sorting_task ALTER COLUMN id SET DEFAULT nextval('public.warehouse_sorting_task_id_seq'::regclass);


--
-- Name: alert_record alert_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_record
    ADD CONSTRAINT alert_record_pkey PRIMARY KEY (id);


--
-- Name: alert_rule alert_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alert_rule
    ADD CONSTRAINT alert_rule_pkey PRIMARY KEY (id);


--
-- Name: billing_rule billing_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_rule
    ADD CONSTRAINT billing_rule_pkey PRIMARY KEY (id);


--
-- Name: customs_declaration customs_declaration_declaration_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customs_declaration
    ADD CONSTRAINT customs_declaration_declaration_no_key UNIQUE (declaration_no);


--
-- Name: customs_declaration customs_declaration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customs_declaration
    ADD CONSTRAINT customs_declaration_pkey PRIMARY KEY (id);


--
-- Name: delivery_task delivery_task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_task
    ADD CONSTRAINT delivery_task_pkey PRIMARY KEY (id);


--
-- Name: delivery_task delivery_task_task_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_task
    ADD CONSTRAINT delivery_task_task_no_key UNIQUE (task_no);


--
-- Name: file_record file_record_file_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_record
    ADD CONSTRAINT file_record_file_no_key UNIQUE (file_no);


--
-- Name: file_record file_record_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_record
    ADD CONSTRAINT file_record_pkey PRIMARY KEY (id);


--
-- Name: file_template file_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_template
    ADD CONSTRAINT file_template_pkey PRIMARY KEY (id);


--
-- Name: invoice invoice_invoice_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_invoice_no_key UNIQUE (invoice_no);


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (id);


--
-- Name: payment payment_payment_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_no_key UNIQUE (payment_no);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: pickup_point pickup_point_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pickup_point
    ADD CONSTRAINT pickup_point_pkey PRIMARY KEY (id);


--
-- Name: pickup_point pickup_point_point_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pickup_point
    ADD CONSTRAINT pickup_point_point_code_key UNIQUE (point_code);


--
-- Name: reconciliation reconciliation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation
    ADD CONSTRAINT reconciliation_pkey PRIMARY KEY (id);


--
-- Name: reconciliation reconciliation_recon_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reconciliation
    ADD CONSTRAINT reconciliation_recon_no_key UNIQUE (recon_no);


--
-- Name: settlement settlement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settlement
    ADD CONSTRAINT settlement_pkey PRIMARY KEY (id);


--
-- Name: settlement settlement_settle_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settlement
    ADD CONSTRAINT settlement_settle_no_key UNIQUE (settle_no);


--
-- Name: sign_receipt sign_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sign_receipt
    ADD CONSTRAINT sign_receipt_pkey PRIMARY KEY (id);


--
-- Name: sign_receipt sign_receipt_receipt_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sign_receipt
    ADD CONSTRAINT sign_receipt_receipt_no_key UNIQUE (receipt_no);


--
-- Name: sorting_task sorting_task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sorting_task
    ADD CONSTRAINT sorting_task_pkey PRIMARY KEY (id);


--
-- Name: sorting_task sorting_task_task_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sorting_task
    ADD CONSTRAINT sorting_task_task_no_key UNIQUE (task_no);


--
-- Name: sys_operation_log sys_operation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_operation_log
    ADD CONSTRAINT sys_operation_log_pkey PRIMARY KEY (id);


--
-- Name: sys_permission sys_permission_perm_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_perm_code_key UNIQUE (perm_code);


--
-- Name: sys_permission sys_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_permission
    ADD CONSTRAINT sys_permission_pkey PRIMARY KEY (id);


--
-- Name: sys_role_permission sys_role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT sys_role_permission_pkey PRIMARY KEY (id);


--
-- Name: sys_role sys_role_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role
    ADD CONSTRAINT sys_role_pkey PRIMARY KEY (id);


--
-- Name: sys_role sys_role_role_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role
    ADD CONSTRAINT sys_role_role_code_key UNIQUE (role_code);


--
-- Name: sys_user sys_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_pkey PRIMARY KEY (id);


--
-- Name: sys_user sys_user_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_username_key UNIQUE (username);


--
-- Name: tracking_log tracking_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_log
    ADD CONSTRAINT tracking_log_pkey PRIMARY KEY (id);


--
-- Name: tracking_package tracking_package_package_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_package
    ADD CONSTRAINT tracking_package_package_no_key UNIQUE (package_no);


--
-- Name: tracking_package tracking_package_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_package
    ADD CONSTRAINT tracking_package_pkey PRIMARY KEY (id);


--
-- Name: transport_task transport_task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_task
    ADD CONSTRAINT transport_task_pkey PRIMARY KEY (id);


--
-- Name: transport_task transport_task_task_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_task
    ADD CONSTRAINT transport_task_task_no_key UNIQUE (task_no);


--
-- Name: transport_vehicle transport_vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_vehicle
    ADD CONSTRAINT transport_vehicle_pkey PRIMARY KEY (id);


--
-- Name: transport_vehicle transport_vehicle_plate_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_vehicle
    ADD CONSTRAINT transport_vehicle_plate_no_key UNIQUE (plate_no);


--
-- Name: sys_role_permission uq_role_perm; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT uq_role_perm UNIQUE (role_id, permission_id);


--
-- Name: warehouse_inventory warehouse_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_inventory
    ADD CONSTRAINT warehouse_inventory_pkey PRIMARY KEY (id);


--
-- Name: warehouse_inventory warehouse_inventory_sku_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_inventory
    ADD CONSTRAINT warehouse_inventory_sku_code_key UNIQUE (sku_code);


--
-- Name: warehouse_receipt warehouse_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_receipt
    ADD CONSTRAINT warehouse_receipt_pkey PRIMARY KEY (id);


--
-- Name: warehouse_receipt warehouse_receipt_receipt_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_receipt
    ADD CONSTRAINT warehouse_receipt_receipt_no_key UNIQUE (receipt_no);


--
-- Name: warehouse_sorting_task warehouse_sorting_task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_sorting_task
    ADD CONSTRAINT warehouse_sorting_task_pkey PRIMARY KEY (id);


--
-- Name: warehouse_sorting_task warehouse_sorting_task_task_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warehouse_sorting_task
    ADD CONSTRAINT warehouse_sorting_task_task_no_key UNIQUE (task_no);


--
-- Name: delivery_task delivery_task_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_task
    ADD CONSTRAINT delivery_task_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_point(id);


--
-- Name: invoice invoice_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment(id);


--
-- Name: payment payment_settle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_settle_id_fkey FOREIGN KEY (settle_id) REFERENCES public.settlement(id);


--
-- Name: settlement settlement_recon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settlement
    ADD CONSTRAINT settlement_recon_id_fkey FOREIGN KEY (recon_id) REFERENCES public.reconciliation(id);


--
-- Name: sign_receipt sign_receipt_delivery_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sign_receipt
    ADD CONSTRAINT sign_receipt_delivery_task_id_fkey FOREIGN KEY (delivery_task_id) REFERENCES public.delivery_task(id);


--
-- Name: sign_receipt sign_receipt_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sign_receipt
    ADD CONSTRAINT sign_receipt_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_point(id);


--
-- Name: sorting_task sorting_task_target_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sorting_task
    ADD CONSTRAINT sorting_task_target_point_id_fkey FOREIGN KEY (target_point_id) REFERENCES public.pickup_point(id);


--
-- Name: sys_role_permission sys_role_permission_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT sys_role_permission_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.sys_permission(id);


--
-- Name: sys_role_permission sys_role_permission_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_role_permission
    ADD CONSTRAINT sys_role_permission_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.sys_role(id);


--
-- Name: sys_user sys_user_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sys_user
    ADD CONSTRAINT sys_user_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.sys_role(id);


--
-- Name: transport_task transport_task_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_task
    ADD CONSTRAINT transport_task_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.transport_vehicle(id);


--
-- PostgreSQL database dump complete
--

\unrestrict m1gxDdElthgkOYzZgw6edSIauFeIAk8YjXpQiP0m0gun3JGimjCyGH4OuFN2PFh

