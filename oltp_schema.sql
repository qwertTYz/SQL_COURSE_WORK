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
-- Name: normalize_customer_fields(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.normalize_customer_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	NEW.Gender := LOWER(NEW.Gender);	
	
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.normalize_customer_fields() OWNER TO postgres;

--
-- Name: normalize_order_fields(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.normalize_order_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	NEW.Order_Status := LOWER(NEW.Order_Status);
	NEW.Way_Of_Payment := LOWER(NEW.Way_Of_Payment);
	
	IF NEW.Order_Status NOT IN ('completed', 'cancelled') THEN
		NEW.End_Date := NULL;
	END IF;
	
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.normalize_order_fields() OWNER TO postgres;

--
-- Name: recalc_order_sum_before(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.recalc_order_sum_before() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.order_sum := (
    SELECT SUM(oi.quantity * p.unit_price)
      FROM order_items oi
      JOIN products p ON oi.order_items_product_id = p.product_id
     WHERE oi.order_items_order_id = NEW.order_id
  );
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.recalc_order_sum_before() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.addresses (
    address_id integer NOT NULL,
    address_name text NOT NULL,
    postal_code text NOT NULL,
    address_city_id integer NOT NULL
);


ALTER TABLE public.addresses OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.addresses_address_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.addresses_address_id_seq OWNER TO postgres;

--
-- Name: addresses_address_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.addresses_address_id_seq OWNED BY public.addresses.address_id;


--
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brands (
    brand_id integer NOT NULL,
    brand_name text NOT NULL,
    brand_address_id integer NOT NULL
);


ALTER TABLE public.brands OWNER TO postgres;

--
-- Name: brands_brand_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brands_brand_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.brands_brand_id_seq OWNER TO postgres;

--
-- Name: brands_brand_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brands_brand_id_seq OWNED BY public.brands.brand_id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    category_name text NOT NULL,
    category_description text
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cities (
    city_id integer NOT NULL,
    city_name text NOT NULL,
    city_country_id integer NOT NULL
);


ALTER TABLE public.cities OWNER TO postgres;

--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cities_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cities_city_id_seq OWNER TO postgres;

--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cities_city_id_seq OWNED BY public.cities.city_id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    country_id integer NOT NULL,
    country_name text NOT NULL
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: countries_country_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.countries_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.countries_country_id_seq OWNER TO postgres;

--
-- Name: countries_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.countries_country_id_seq OWNED BY public.countries.country_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    gender text,
    email text NOT NULL,
    customer_password text NOT NULL,
    phone_number text,
    date_of_birth date NOT NULL,
    member_since date DEFAULT CURRENT_DATE NOT NULL,
    CONSTRAINT customers_check CHECK (((member_since >= '1994-01-01'::date) AND (member_since <= CURRENT_DATE) AND (member_since > date_of_birth))),
    CONSTRAINT customers_gender_check CHECK ((gender = ANY (ARRAY['male'::text, 'female'::text, 'not specified'::text])))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_customer_id_seq OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.manufacturers (
    manufacturer_id integer NOT NULL,
    manufacturer_name text NOT NULL,
    manufacturer_address_id integer NOT NULL
);


ALTER TABLE public.manufacturers OWNER TO postgres;

--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.manufacturers_manufacturer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.manufacturers_manufacturer_id_seq OWNER TO postgres;

--
-- Name: manufacturers_manufacturer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.manufacturers_manufacturer_id_seq OWNED BY public.manufacturers.manufacturer_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id integer NOT NULL,
    order_items_order_id integer NOT NULL,
    order_items_product_id integer NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    order_customer_id integer,
    order_status text NOT NULL,
    way_of_payment text NOT NULL,
    delivery_address_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    order_sum numeric(10,2) DEFAULT 0,
    CONSTRAINT orders_check CHECK (((end_date <= CURRENT_DATE) AND (end_date >= start_date))),
    CONSTRAINT orders_order_status_check CHECK ((order_status = ANY (ARRAY['basket'::text, 'completed'::text, 'cancelled'::text, 'submitted'::text, 'approved'::text, 'in progress'::text, 'delivered'::text]))),
    CONSTRAINT orders_order_sum_check CHECK ((order_sum >= (0)::numeric)),
    CONSTRAINT orders_start_date_check CHECK ((start_date >= '1994-01-01'::date)),
    CONSTRAINT orders_way_of_payment_check CHECK ((way_of_payment = ANY (ARRAY['cash'::text, 'card'::text, 'bank transfer'::text])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id integer NOT NULL,
    product_category_id integer NOT NULL,
    product_name text,
    product_description text,
    unit_price numeric(10,2) NOT NULL,
    product_manufacturer_id integer NOT NULL,
    product_brand_id integer NOT NULL,
    CONSTRAINT products_unit_price_check CHECK ((unit_price > (0)::numeric))
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_product_id_seq OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: tmp_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_addresses (
    address_name text,
    postal_code text,
    city_name text
);


ALTER TABLE public.tmp_addresses OWNER TO postgres;

--
-- Name: tmp_brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_brands (
    brand_name text,
    address_name text
);


ALTER TABLE public.tmp_brands OWNER TO postgres;

--
-- Name: tmp_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_categories (
    category_name text,
    category_description text
);


ALTER TABLE public.tmp_categories OWNER TO postgres;

--
-- Name: tmp_cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_cities (
    city_name text,
    country_name text
);


ALTER TABLE public.tmp_cities OWNER TO postgres;

--
-- Name: tmp_countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_countries (
    country_name text
);


ALTER TABLE public.tmp_countries OWNER TO postgres;

--
-- Name: tmp_customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_customers (
    first_name text,
    last_name text,
    gender text,
    email text,
    customer_password text,
    phone_number text,
    date_of_birth date,
    member_since date
);


ALTER TABLE public.tmp_customers OWNER TO postgres;

--
-- Name: tmp_manufacturers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_manufacturers (
    manufacturer_name text,
    address_name text
);


ALTER TABLE public.tmp_manufacturers OWNER TO postgres;

--
-- Name: tmp_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_order_items (
    order_start_date date,
    customer_email text,
    product_name text,
    quantity integer
);


ALTER TABLE public.tmp_order_items OWNER TO postgres;

--
-- Name: tmp_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_orders (
    customer_email text,
    order_status text,
    way_of_payment text,
    delivery_address_name text,
    start_date date,
    end_date date,
    order_sum numeric(10,2)
);


ALTER TABLE public.tmp_orders OWNER TO postgres;

--
-- Name: tmp_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tmp_products (
    product_name text,
    product_description text,
    unit_price numeric,
    category_name text,
    manufacturer_name text,
    brand_name text
);


ALTER TABLE public.tmp_products OWNER TO postgres;

--
-- Name: addresses address_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses ALTER COLUMN address_id SET DEFAULT nextval('public.addresses_address_id_seq'::regclass);


--
-- Name: brands brand_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands ALTER COLUMN brand_id SET DEFAULT nextval('public.brands_brand_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: cities city_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities ALTER COLUMN city_id SET DEFAULT nextval('public.cities_city_id_seq'::regclass);


--
-- Name: countries country_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries ALTER COLUMN country_id SET DEFAULT nextval('public.countries_country_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: manufacturers manufacturer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturers ALTER COLUMN manufacturer_id SET DEFAULT nextval('public.manufacturers_manufacturer_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: addresses addresses_address_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_address_name_key UNIQUE (address_name);


--
-- Name: addresses addresses_name_city_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_name_city_unique UNIQUE (address_name, address_city_id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);


--
-- Name: addresses addresses_postal_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_postal_code_key UNIQUE (postal_code);


--
-- Name: brands brands_brand_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_brand_name_key UNIQUE (brand_name);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (brand_id);


--
-- Name: categories categories_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_category_name_key UNIQUE (category_name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: countries countries_country_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_country_name_key UNIQUE (country_name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_number_key UNIQUE (phone_number);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: manufacturers manufacturers_manufacturer_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_manufacturer_name_key UNIQUE (manufacturer_name);


--
-- Name: manufacturers manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (manufacturer_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: cities uq_city_per_country; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT uq_city_per_country UNIQUE (city_name, city_country_id);


--
-- Name: orders uq_orders_natural; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT uq_orders_natural UNIQUE (order_customer_id, order_status, way_of_payment, delivery_address_id, start_date, end_date, order_sum);


--
-- Name: customers trg_normalize_customer_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_normalize_customer_fields BEFORE INSERT OR UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.normalize_customer_fields();


--
-- Name: orders trg_normalize_order_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_normalize_order_fields BEFORE INSERT OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.normalize_order_fields();


--
-- Name: orders trg_recalc_order_sum; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_recalc_order_sum BEFORE INSERT OR UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.recalc_order_sum_before();


--
-- Name: addresses addresses_address_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_address_city_id_fkey FOREIGN KEY (address_city_id) REFERENCES public.cities(city_id);


--
-- Name: brands brands_brand_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_brand_address_id_fkey FOREIGN KEY (brand_address_id) REFERENCES public.addresses(address_id);


--
-- Name: cities cities_city_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_city_country_id_fkey FOREIGN KEY (city_country_id) REFERENCES public.countries(country_id);


--
-- Name: manufacturers manufacturers_manufacturer_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.manufacturers
    ADD CONSTRAINT manufacturers_manufacturer_address_id_fkey FOREIGN KEY (manufacturer_address_id) REFERENCES public.addresses(address_id);


--
-- Name: order_items order_items_order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_items_order_id_fkey FOREIGN KEY (order_items_order_id) REFERENCES public.orders(order_id);


--
-- Name: order_items order_items_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_items_product_id_fkey FOREIGN KEY (order_items_product_id) REFERENCES public.products(product_id);


--
-- Name: orders orders_delivery_address_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_delivery_address_id_fkey FOREIGN KEY (delivery_address_id) REFERENCES public.addresses(address_id);


--
-- Name: orders orders_order_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_order_customer_id_fkey FOREIGN KEY (order_customer_id) REFERENCES public.customers(customer_id);


--
-- Name: products products_product_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_brand_id_fkey FOREIGN KEY (product_brand_id) REFERENCES public.brands(brand_id);


--
-- Name: products products_product_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_category_id_fkey FOREIGN KEY (product_category_id) REFERENCES public.categories(category_id);


--
-- Name: products products_product_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_product_manufacturer_id_fkey FOREIGN KEY (product_manufacturer_id) REFERENCES public.manufacturers(manufacturer_id);


--
-- PostgreSQL database dump complete
--

