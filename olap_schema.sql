--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: staging; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA staging;


ALTER SCHEMA staging OWNER TO postgres;

--
-- Name: postgres_fdw; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgres_fdw WITH SCHEMA public;


--
-- Name: EXTENSION postgres_fdw; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgres_fdw IS 'foreign-data wrapper for remote PostgreSQL servers';


--
-- Name: oltp_fdw; Type: SERVER; Schema: -; Owner: postgres
--

CREATE SERVER oltp_fdw FOREIGN DATA WRAPPER postgres_fdw OPTIONS (
    dbname 'COURSE_WORK_OLTP',
    host 'localhost',
    port '5432'
);


ALTER SERVER oltp_fdw OWNER TO postgres;

--
-- Name: USER MAPPING postgres SERVER oltp_fdw; Type: USER MAPPING; Schema: -; Owner: postgres
--

CREATE USER MAPPING FOR postgres SERVER oltp_fdw OPTIONS (
    password 'password',
    "user" 'postgres'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bridge_product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bridge_product_category (
    product_sk integer NOT NULL,
    category_sk integer NOT NULL
);


ALTER TABLE public.bridge_product_category OWNER TO postgres;

--
-- Name: dim_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_address (
    address_sk integer NOT NULL,
    address_name text NOT NULL,
    postal_code text,
    city_sk integer NOT NULL
);


ALTER TABLE public.dim_address OWNER TO postgres;

--
-- Name: dim_address_address_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_address_address_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_address_address_sk_seq OWNER TO postgres;

--
-- Name: dim_address_address_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_address_address_sk_seq OWNED BY public.dim_address.address_sk;


--
-- Name: dim_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_category (
    category_sk integer NOT NULL,
    category_name text
);


ALTER TABLE public.dim_category OWNER TO postgres;

--
-- Name: dim_category_category_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_category_category_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_category_category_sk_seq OWNER TO postgres;

--
-- Name: dim_category_category_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_category_category_sk_seq OWNED BY public.dim_category.category_sk;


--
-- Name: dim_city; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_city (
    city_sk integer NOT NULL,
    city_name text,
    country_sk integer NOT NULL
);


ALTER TABLE public.dim_city OWNER TO postgres;

--
-- Name: dim_city_city_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_city_city_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_city_city_sk_seq OWNER TO postgres;

--
-- Name: dim_city_city_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_city_city_sk_seq OWNED BY public.dim_city.city_sk;


--
-- Name: dim_country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_country (
    country_sk integer NOT NULL,
    country_name text
);


ALTER TABLE public.dim_country OWNER TO postgres;

--
-- Name: dim_country_country_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_country_country_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_country_country_sk_seq OWNER TO postgres;

--
-- Name: dim_country_country_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_country_country_sk_seq OWNED BY public.dim_country.country_sk;


--
-- Name: dim_customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_customer (
    customer_sk integer NOT NULL,
    customer_id text,
    first_name text,
    last_name text,
    gender text,
    date_of_birth date,
    email text,
    phone_number text,
    effective_from date NOT NULL,
    effective_to date,
    is_current boolean DEFAULT true NOT NULL
);


ALTER TABLE public.dim_customer OWNER TO postgres;

--
-- Name: dim_customer_customer_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_customer_customer_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_customer_customer_sk_seq OWNER TO postgres;

--
-- Name: dim_customer_customer_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_customer_customer_sk_seq OWNED BY public.dim_customer.customer_sk;


--
-- Name: dim_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_product (
    product_sk integer NOT NULL,
    product_id text,
    product_name text,
    unit_price numeric(10,2),
    manufacturer text,
    brand text
);


ALTER TABLE public.dim_product OWNER TO postgres;

--
-- Name: dim_product_product_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_product_product_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_product_product_sk_seq OWNER TO postgres;

--
-- Name: dim_product_product_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_product_product_sk_seq OWNED BY public.dim_product.product_sk;


--
-- Name: dim_time; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_time (
    time_sk integer NOT NULL,
    full_date date,
    day integer,
    month integer,
    quarter integer,
    year integer
);


ALTER TABLE public.dim_time OWNER TO postgres;

--
-- Name: dim_time_time_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dim_time_time_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dim_time_time_sk_seq OWNER TO postgres;

--
-- Name: dim_time_time_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dim_time_time_sk_seq OWNED BY public.dim_time.time_sk;


--
-- Name: fact_daily_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_daily_sales (
    day_sk integer NOT NULL,
    date_sk integer,
    total_orders bigint,
    total_revenue numeric(10,2)
);


ALTER TABLE public.fact_daily_sales OWNER TO postgres;

--
-- Name: fact_daily_sales_day_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fact_daily_sales_day_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fact_daily_sales_day_sk_seq OWNER TO postgres;

--
-- Name: fact_daily_sales_day_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fact_daily_sales_day_sk_seq OWNED BY public.fact_daily_sales.day_sk;


--
-- Name: fact_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_order_items (
    item_sk integer NOT NULL,
    order_sk integer,
    product_sk integer,
    quantity_sold integer,
    item_price numeric(10,2),
    item_revenue numeric(10,2)
);


ALTER TABLE public.fact_order_items OWNER TO postgres;

--
-- Name: fact_order_items_item_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fact_order_items_item_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fact_order_items_item_sk_seq OWNER TO postgres;

--
-- Name: fact_order_items_item_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fact_order_items_item_sk_seq OWNED BY public.fact_order_items.item_sk;


--
-- Name: fact_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fact_orders (
    order_sk integer NOT NULL,
    customer_sk integer,
    address_sk integer,
    time_sk integer,
    total_orders bigint,
    total_revenue numeric(10,2)
);


ALTER TABLE public.fact_orders OWNER TO postgres;

--
-- Name: fact_orders_order_sk_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fact_orders_order_sk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fact_orders_order_sk_seq OWNER TO postgres;

--
-- Name: fact_orders_order_sk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fact_orders_order_sk_seq OWNED BY public.fact_orders.order_sk;


--
-- Name: addresses; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.addresses (
    address_id integer NOT NULL,
    address_name text NOT NULL,
    postal_code text NOT NULL,
    address_city_id integer NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'addresses'
);
ALTER FOREIGN TABLE ONLY staging.addresses ALTER COLUMN address_id OPTIONS (
    column_name 'address_id'
);
ALTER FOREIGN TABLE ONLY staging.addresses ALTER COLUMN address_name OPTIONS (
    column_name 'address_name'
);
ALTER FOREIGN TABLE ONLY staging.addresses ALTER COLUMN postal_code OPTIONS (
    column_name 'postal_code'
);
ALTER FOREIGN TABLE ONLY staging.addresses ALTER COLUMN address_city_id OPTIONS (
    column_name 'address_city_id'
);


ALTER FOREIGN TABLE staging.addresses OWNER TO postgres;

--
-- Name: brands; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.brands (
    brand_id integer NOT NULL,
    brand_name text NOT NULL,
    brand_address_id integer NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'brands'
);
ALTER FOREIGN TABLE ONLY staging.brands ALTER COLUMN brand_id OPTIONS (
    column_name 'brand_id'
);
ALTER FOREIGN TABLE ONLY staging.brands ALTER COLUMN brand_name OPTIONS (
    column_name 'brand_name'
);
ALTER FOREIGN TABLE ONLY staging.brands ALTER COLUMN brand_address_id OPTIONS (
    column_name 'brand_address_id'
);


ALTER FOREIGN TABLE staging.brands OWNER TO postgres;

--
-- Name: categories; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.categories (
    category_id integer NOT NULL,
    category_name text NOT NULL,
    category_description text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'categories'
);
ALTER FOREIGN TABLE ONLY staging.categories ALTER COLUMN category_id OPTIONS (
    column_name 'category_id'
);
ALTER FOREIGN TABLE ONLY staging.categories ALTER COLUMN category_name OPTIONS (
    column_name 'category_name'
);
ALTER FOREIGN TABLE ONLY staging.categories ALTER COLUMN category_description OPTIONS (
    column_name 'category_description'
);


ALTER FOREIGN TABLE staging.categories OWNER TO postgres;

--
-- Name: cities; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.cities (
    city_id integer NOT NULL,
    city_name text NOT NULL,
    city_country_id integer NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'cities'
);
ALTER FOREIGN TABLE ONLY staging.cities ALTER COLUMN city_id OPTIONS (
    column_name 'city_id'
);
ALTER FOREIGN TABLE ONLY staging.cities ALTER COLUMN city_name OPTIONS (
    column_name 'city_name'
);
ALTER FOREIGN TABLE ONLY staging.cities ALTER COLUMN city_country_id OPTIONS (
    column_name 'city_country_id'
);


ALTER FOREIGN TABLE staging.cities OWNER TO postgres;

--
-- Name: countries; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.countries (
    country_id integer NOT NULL,
    country_name text NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'countries'
);
ALTER FOREIGN TABLE ONLY staging.countries ALTER COLUMN country_id OPTIONS (
    column_name 'country_id'
);
ALTER FOREIGN TABLE ONLY staging.countries ALTER COLUMN country_name OPTIONS (
    column_name 'country_name'
);


ALTER FOREIGN TABLE staging.countries OWNER TO postgres;

--
-- Name: customers; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.customers (
    customer_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    gender text,
    email text NOT NULL,
    customer_password text NOT NULL,
    phone_number text,
    date_of_birth date NOT NULL,
    member_since date NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'customers'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN customer_id OPTIONS (
    column_name 'customer_id'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN first_name OPTIONS (
    column_name 'first_name'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN last_name OPTIONS (
    column_name 'last_name'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN gender OPTIONS (
    column_name 'gender'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN customer_password OPTIONS (
    column_name 'customer_password'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN phone_number OPTIONS (
    column_name 'phone_number'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN date_of_birth OPTIONS (
    column_name 'date_of_birth'
);
ALTER FOREIGN TABLE ONLY staging.customers ALTER COLUMN member_since OPTIONS (
    column_name 'member_since'
);


ALTER FOREIGN TABLE staging.customers OWNER TO postgres;

--
-- Name: manufacturers; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.manufacturers (
    manufacturer_id integer NOT NULL,
    manufacturer_name text NOT NULL,
    manufacturer_address_id integer NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'manufacturers'
);
ALTER FOREIGN TABLE ONLY staging.manufacturers ALTER COLUMN manufacturer_id OPTIONS (
    column_name 'manufacturer_id'
);
ALTER FOREIGN TABLE ONLY staging.manufacturers ALTER COLUMN manufacturer_name OPTIONS (
    column_name 'manufacturer_name'
);
ALTER FOREIGN TABLE ONLY staging.manufacturers ALTER COLUMN manufacturer_address_id OPTIONS (
    column_name 'manufacturer_address_id'
);


ALTER FOREIGN TABLE staging.manufacturers OWNER TO postgres;

--
-- Name: order_items; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.order_items (
    order_item_id integer NOT NULL,
    order_items_order_id integer NOT NULL,
    order_items_product_id integer NOT NULL,
    quantity integer NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'order_items'
);
ALTER FOREIGN TABLE ONLY staging.order_items ALTER COLUMN order_item_id OPTIONS (
    column_name 'order_item_id'
);
ALTER FOREIGN TABLE ONLY staging.order_items ALTER COLUMN order_items_order_id OPTIONS (
    column_name 'order_items_order_id'
);
ALTER FOREIGN TABLE ONLY staging.order_items ALTER COLUMN order_items_product_id OPTIONS (
    column_name 'order_items_product_id'
);
ALTER FOREIGN TABLE ONLY staging.order_items ALTER COLUMN quantity OPTIONS (
    column_name 'quantity'
);


ALTER FOREIGN TABLE staging.order_items OWNER TO postgres;

--
-- Name: orders; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.orders (
    order_id integer NOT NULL,
    order_customer_id integer,
    order_status text NOT NULL,
    way_of_payment text NOT NULL,
    delivery_address_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    order_sum numeric(10,2)
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'orders'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN order_id OPTIONS (
    column_name 'order_id'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN order_customer_id OPTIONS (
    column_name 'order_customer_id'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN order_status OPTIONS (
    column_name 'order_status'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN way_of_payment OPTIONS (
    column_name 'way_of_payment'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN delivery_address_id OPTIONS (
    column_name 'delivery_address_id'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN start_date OPTIONS (
    column_name 'start_date'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN end_date OPTIONS (
    column_name 'end_date'
);
ALTER FOREIGN TABLE ONLY staging.orders ALTER COLUMN order_sum OPTIONS (
    column_name 'order_sum'
);


ALTER FOREIGN TABLE staging.orders OWNER TO postgres;

--
-- Name: products; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.products (
    product_id integer NOT NULL,
    product_category_id integer NOT NULL,
    product_name text,
    product_description text,
    unit_price numeric(10,2) NOT NULL,
    product_manufacturer_id integer NOT NULL,
    product_brand_id integer NOT NULL
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'products'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN product_id OPTIONS (
    column_name 'product_id'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN product_category_id OPTIONS (
    column_name 'product_category_id'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN product_name OPTIONS (
    column_name 'product_name'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN product_description OPTIONS (
    column_name 'product_description'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN unit_price OPTIONS (
    column_name 'unit_price'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN product_manufacturer_id OPTIONS (
    column_name 'product_manufacturer_id'
);
ALTER FOREIGN TABLE ONLY staging.products ALTER COLUMN product_brand_id OPTIONS (
    column_name 'product_brand_id'
);


ALTER FOREIGN TABLE staging.products OWNER TO postgres;

--
-- Name: tmp_addresses; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_addresses (
    address_name text,
    postal_code text,
    city_name text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_addresses'
);
ALTER FOREIGN TABLE ONLY staging.tmp_addresses ALTER COLUMN address_name OPTIONS (
    column_name 'address_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_addresses ALTER COLUMN postal_code OPTIONS (
    column_name 'postal_code'
);
ALTER FOREIGN TABLE ONLY staging.tmp_addresses ALTER COLUMN city_name OPTIONS (
    column_name 'city_name'
);


ALTER FOREIGN TABLE staging.tmp_addresses OWNER TO postgres;

--
-- Name: tmp_brands; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_brands (
    brand_name text,
    address_name text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_brands'
);
ALTER FOREIGN TABLE ONLY staging.tmp_brands ALTER COLUMN brand_name OPTIONS (
    column_name 'brand_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_brands ALTER COLUMN address_name OPTIONS (
    column_name 'address_name'
);


ALTER FOREIGN TABLE staging.tmp_brands OWNER TO postgres;

--
-- Name: tmp_categories; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_categories (
    category_name text,
    category_description text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_categories'
);
ALTER FOREIGN TABLE ONLY staging.tmp_categories ALTER COLUMN category_name OPTIONS (
    column_name 'category_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_categories ALTER COLUMN category_description OPTIONS (
    column_name 'category_description'
);


ALTER FOREIGN TABLE staging.tmp_categories OWNER TO postgres;

--
-- Name: tmp_cities; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_cities (
    city_name text,
    country_name text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_cities'
);
ALTER FOREIGN TABLE ONLY staging.tmp_cities ALTER COLUMN city_name OPTIONS (
    column_name 'city_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_cities ALTER COLUMN country_name OPTIONS (
    column_name 'country_name'
);


ALTER FOREIGN TABLE staging.tmp_cities OWNER TO postgres;

--
-- Name: tmp_countries; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_countries (
    country_name text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_countries'
);
ALTER FOREIGN TABLE ONLY staging.tmp_countries ALTER COLUMN country_name OPTIONS (
    column_name 'country_name'
);


ALTER FOREIGN TABLE staging.tmp_countries OWNER TO postgres;

--
-- Name: tmp_customers; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_customers (
    first_name text,
    last_name text,
    gender text,
    email text,
    customer_password text,
    phone_number text,
    date_of_birth date,
    member_since date
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_customers'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN first_name OPTIONS (
    column_name 'first_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN last_name OPTIONS (
    column_name 'last_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN gender OPTIONS (
    column_name 'gender'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN email OPTIONS (
    column_name 'email'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN customer_password OPTIONS (
    column_name 'customer_password'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN phone_number OPTIONS (
    column_name 'phone_number'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN date_of_birth OPTIONS (
    column_name 'date_of_birth'
);
ALTER FOREIGN TABLE ONLY staging.tmp_customers ALTER COLUMN member_since OPTIONS (
    column_name 'member_since'
);


ALTER FOREIGN TABLE staging.tmp_customers OWNER TO postgres;

--
-- Name: tmp_manufacturers; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_manufacturers (
    manufacturer_name text,
    address_name text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_manufacturers'
);
ALTER FOREIGN TABLE ONLY staging.tmp_manufacturers ALTER COLUMN manufacturer_name OPTIONS (
    column_name 'manufacturer_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_manufacturers ALTER COLUMN address_name OPTIONS (
    column_name 'address_name'
);


ALTER FOREIGN TABLE staging.tmp_manufacturers OWNER TO postgres;

--
-- Name: tmp_order_items; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_order_items (
    order_start_date date,
    customer_email text,
    product_name text,
    quantity integer
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_order_items'
);
ALTER FOREIGN TABLE ONLY staging.tmp_order_items ALTER COLUMN order_start_date OPTIONS (
    column_name 'order_start_date'
);
ALTER FOREIGN TABLE ONLY staging.tmp_order_items ALTER COLUMN customer_email OPTIONS (
    column_name 'customer_email'
);
ALTER FOREIGN TABLE ONLY staging.tmp_order_items ALTER COLUMN product_name OPTIONS (
    column_name 'product_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_order_items ALTER COLUMN quantity OPTIONS (
    column_name 'quantity'
);


ALTER FOREIGN TABLE staging.tmp_order_items OWNER TO postgres;

--
-- Name: tmp_orders; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_orders (
    customer_email text,
    order_status text,
    way_of_payment text,
    delivery_address_name text,
    start_date date,
    end_date date,
    order_sum numeric(10,2)
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_orders'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN customer_email OPTIONS (
    column_name 'customer_email'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN order_status OPTIONS (
    column_name 'order_status'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN way_of_payment OPTIONS (
    column_name 'way_of_payment'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN delivery_address_name OPTIONS (
    column_name 'delivery_address_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN start_date OPTIONS (
    column_name 'start_date'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN end_date OPTIONS (
    column_name 'end_date'
);
ALTER FOREIGN TABLE ONLY staging.tmp_orders ALTER COLUMN order_sum OPTIONS (
    column_name 'order_sum'
);


ALTER FOREIGN TABLE staging.tmp_orders OWNER TO postgres;

--
-- Name: tmp_products; Type: FOREIGN TABLE; Schema: staging; Owner: postgres
--

CREATE FOREIGN TABLE staging.tmp_products (
    product_name text,
    product_description text,
    unit_price numeric,
    category_name text,
    manufacturer_name text,
    brand_name text
)
SERVER oltp_fdw
OPTIONS (
    schema_name 'public',
    table_name 'tmp_products'
);
ALTER FOREIGN TABLE ONLY staging.tmp_products ALTER COLUMN product_name OPTIONS (
    column_name 'product_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_products ALTER COLUMN product_description OPTIONS (
    column_name 'product_description'
);
ALTER FOREIGN TABLE ONLY staging.tmp_products ALTER COLUMN unit_price OPTIONS (
    column_name 'unit_price'
);
ALTER FOREIGN TABLE ONLY staging.tmp_products ALTER COLUMN category_name OPTIONS (
    column_name 'category_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_products ALTER COLUMN manufacturer_name OPTIONS (
    column_name 'manufacturer_name'
);
ALTER FOREIGN TABLE ONLY staging.tmp_products ALTER COLUMN brand_name OPTIONS (
    column_name 'brand_name'
);


ALTER FOREIGN TABLE staging.tmp_products OWNER TO postgres;

--
-- Name: dim_address address_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_address ALTER COLUMN address_sk SET DEFAULT nextval('public.dim_address_address_sk_seq'::regclass);


--
-- Name: dim_category category_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_category ALTER COLUMN category_sk SET DEFAULT nextval('public.dim_category_category_sk_seq'::regclass);


--
-- Name: dim_city city_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_city ALTER COLUMN city_sk SET DEFAULT nextval('public.dim_city_city_sk_seq'::regclass);


--
-- Name: dim_country country_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_country ALTER COLUMN country_sk SET DEFAULT nextval('public.dim_country_country_sk_seq'::regclass);


--
-- Name: dim_customer customer_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_customer ALTER COLUMN customer_sk SET DEFAULT nextval('public.dim_customer_customer_sk_seq'::regclass);


--
-- Name: dim_product product_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_product ALTER COLUMN product_sk SET DEFAULT nextval('public.dim_product_product_sk_seq'::regclass);


--
-- Name: dim_time time_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_time ALTER COLUMN time_sk SET DEFAULT nextval('public.dim_time_time_sk_seq'::regclass);


--
-- Name: fact_daily_sales day_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_daily_sales ALTER COLUMN day_sk SET DEFAULT nextval('public.fact_daily_sales_day_sk_seq'::regclass);


--
-- Name: fact_order_items item_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_order_items ALTER COLUMN item_sk SET DEFAULT nextval('public.fact_order_items_item_sk_seq'::regclass);


--
-- Name: fact_orders order_sk; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_orders ALTER COLUMN order_sk SET DEFAULT nextval('public.fact_orders_order_sk_seq'::regclass);


--
-- Name: bridge_product_category bridge_product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bridge_product_category
    ADD CONSTRAINT bridge_product_category_pkey PRIMARY KEY (product_sk, category_sk);


--
-- Name: dim_address dim_address_address_name_postal_code_city_sk_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_address
    ADD CONSTRAINT dim_address_address_name_postal_code_city_sk_key UNIQUE (address_name, postal_code, city_sk);


--
-- Name: dim_address dim_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_address
    ADD CONSTRAINT dim_address_pkey PRIMARY KEY (address_sk);


--
-- Name: dim_category dim_category_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_category
    ADD CONSTRAINT dim_category_category_name_key UNIQUE (category_name);


--
-- Name: dim_category dim_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_category
    ADD CONSTRAINT dim_category_pkey PRIMARY KEY (category_sk);


--
-- Name: dim_city dim_city_city_name_country_sk_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_city
    ADD CONSTRAINT dim_city_city_name_country_sk_key UNIQUE (city_name, country_sk);


--
-- Name: dim_city dim_city_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_city
    ADD CONSTRAINT dim_city_pkey PRIMARY KEY (city_sk);


--
-- Name: dim_country dim_country_country_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_country
    ADD CONSTRAINT dim_country_country_name_key UNIQUE (country_name);


--
-- Name: dim_country dim_country_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_country
    ADD CONSTRAINT dim_country_pkey PRIMARY KEY (country_sk);


--
-- Name: dim_customer dim_customer_customer_id_effective_from_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_customer
    ADD CONSTRAINT dim_customer_customer_id_effective_from_key UNIQUE (customer_id, effective_from);


--
-- Name: dim_customer dim_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_customer
    ADD CONSTRAINT dim_customer_pkey PRIMARY KEY (customer_sk);


--
-- Name: dim_product dim_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_product
    ADD CONSTRAINT dim_product_pkey PRIMARY KEY (product_sk);


--
-- Name: dim_product dim_product_product_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_product
    ADD CONSTRAINT dim_product_product_id_key UNIQUE (product_id);


--
-- Name: dim_time dim_time_full_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_time
    ADD CONSTRAINT dim_time_full_date_key UNIQUE (full_date);


--
-- Name: dim_time dim_time_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_time
    ADD CONSTRAINT dim_time_pkey PRIMARY KEY (time_sk);


--
-- Name: fact_daily_sales fact_daily_sales_date_sk_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_daily_sales
    ADD CONSTRAINT fact_daily_sales_date_sk_key UNIQUE (date_sk);


--
-- Name: fact_daily_sales fact_daily_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_daily_sales
    ADD CONSTRAINT fact_daily_sales_pkey PRIMARY KEY (day_sk);


--
-- Name: fact_order_items fact_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_order_items
    ADD CONSTRAINT fact_order_items_pkey PRIMARY KEY (item_sk);


--
-- Name: fact_orders fact_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_orders
    ADD CONSTRAINT fact_orders_pkey PRIMARY KEY (order_sk);


--
-- Name: bridge_product_category bridge_product_category_category_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bridge_product_category
    ADD CONSTRAINT bridge_product_category_category_sk_fkey FOREIGN KEY (category_sk) REFERENCES public.dim_category(category_sk);


--
-- Name: bridge_product_category bridge_product_category_product_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bridge_product_category
    ADD CONSTRAINT bridge_product_category_product_sk_fkey FOREIGN KEY (product_sk) REFERENCES public.dim_product(product_sk);


--
-- Name: dim_address dim_address_city_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_address
    ADD CONSTRAINT dim_address_city_sk_fkey FOREIGN KEY (city_sk) REFERENCES public.dim_city(city_sk);


--
-- Name: dim_city dim_city_country_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dim_city
    ADD CONSTRAINT dim_city_country_sk_fkey FOREIGN KEY (country_sk) REFERENCES public.dim_country(country_sk);


--
-- Name: fact_daily_sales fact_daily_sales_date_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_daily_sales
    ADD CONSTRAINT fact_daily_sales_date_sk_fkey FOREIGN KEY (date_sk) REFERENCES public.dim_time(time_sk);


--
-- Name: fact_order_items fact_order_items_order_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_order_items
    ADD CONSTRAINT fact_order_items_order_sk_fkey FOREIGN KEY (order_sk) REFERENCES public.fact_orders(order_sk);


--
-- Name: fact_order_items fact_order_items_product_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_order_items
    ADD CONSTRAINT fact_order_items_product_sk_fkey FOREIGN KEY (product_sk) REFERENCES public.dim_product(product_sk);


--
-- Name: fact_orders fact_orders_address_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_orders
    ADD CONSTRAINT fact_orders_address_sk_fkey FOREIGN KEY (address_sk) REFERENCES public.dim_address(address_sk);


--
-- Name: fact_orders fact_orders_customer_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_orders
    ADD CONSTRAINT fact_orders_customer_sk_fkey FOREIGN KEY (customer_sk) REFERENCES public.dim_customer(customer_sk);


--
-- Name: fact_orders fact_orders_time_sk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fact_orders
    ADD CONSTRAINT fact_orders_time_sk_fkey FOREIGN KEY (time_sk) REFERENCES public.dim_time(time_sk);


--
-- PostgreSQL database dump complete
--

