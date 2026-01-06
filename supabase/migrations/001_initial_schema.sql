-- ============================================
-- MessMate Database Schema Migration
-- Run this in your Supabase SQL Editor
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- ENUMS
-- ============================================

-- Create user_role enum
CREATE TYPE user_role AS ENUM ('student', 'mess_owner');

-- ============================================
-- TABLES
-- ============================================

-- Profiles table (must be created first as other tables reference it)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT,
    mobile TEXT,
    address TEXT,
    avatar_url TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    role user_role NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mess Services table
CREATE TABLE IF NOT EXISTS public.mess_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    price_monthly DOUBLE PRECISION NOT NULL,
    is_vegetarian BOOLEAN DEFAULT false,
    is_non_vegetarian BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mess Images table
CREATE TABLE IF NOT EXISTS public.mess_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscription Plans table
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price DOUBLE PRECISION NOT NULL,
    duration_days INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payments table
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID NOT NULL REFERENCES public.subscriptions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    amount DOUBLE PRECISION NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    payment_method TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    transaction_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews table
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Menu Items table
CREATE TABLE IF NOT EXISTS public.menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    meal_type TEXT NOT NULL,
    day_of_week TEXT NOT NULL,
    is_vegetarian BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Meal Schedule table
CREATE TABLE IF NOT EXISTS public.meal_schedule (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    day_of_week TEXT NOT NULL,
    meal_type TEXT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory Items table
CREATE TABLE IF NOT EXISTS public.inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    unit TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Announcements table
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    mess_id UUID NOT NULL REFERENCES public.mess_services(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update user location
CREATE OR REPLACE FUNCTION public.update_user_location(
  user_id UUID,
  user_latitude DOUBLE PRECISION,
  user_longitude DOUBLE PRECISION
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.profiles
  SET 
    latitude = user_latitude,
    longitude = user_longitude,
    updated_at = now()
  WHERE id = user_id;
END;
$$;

-- Function to create a profile with a specific ID
CREATE OR REPLACE FUNCTION public.create_profile_with_id(
  profile_id uuid,
  first_name_val text,
  last_name_val text,
  role_val user_role
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    first_name,
    last_name,
    role,
    created_at,
    updated_at
  ) VALUES (
    profile_id,
    first_name_val,
    last_name_val,
    role_val,
    now(),
    now()
  );
END;
$$;

-- Function to create customer profile
CREATE OR REPLACE FUNCTION public.create_customer_profile(
  profile_id uuid,
  first_name_val text,
  last_name_val text,
  address_val text,
  mobile_val text,
  email_val text,
  role_val text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (
    id,
    first_name,
    last_name,
    address,
    mobile,
    email,
    role,
    created_at,
    updated_at
  ) VALUES (
    profile_id,
    first_name_val,
    last_name_val,
    address_val,
    mobile_val,
    email_val,
    role_val::user_role,
    now(),
    now()
  ) ON CONFLICT (id) DO UPDATE SET
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    address = EXCLUDED.address,
    mobile = EXCLUDED.mobile,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    updated_at = now();
END;
$$;

-- Function to check subscription policies
CREATE OR REPLACE FUNCTION public.check_subscription_policies()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN 'RLS policies checked';
END;
$$;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mess_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mess_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meal_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON public.profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Mess Services policies
CREATE POLICY "Anyone can view mess services" ON public.mess_services
  FOR SELECT USING (true);

CREATE POLICY "Mess owners can insert their mess" ON public.mess_services
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Mess owners can update their mess" ON public.mess_services
  FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Mess owners can delete their mess" ON public.mess_services
  FOR DELETE USING (auth.uid() = owner_id);

-- Mess Images policies
CREATE POLICY "Anyone can view mess images" ON public.mess_images
  FOR SELECT USING (true);

CREATE POLICY "Mess owners can manage their mess images" ON public.mess_images
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Subscription Plans policies
CREATE POLICY "Anyone can view subscription plans" ON public.subscription_plans
  FOR SELECT USING (true);

CREATE POLICY "Mess owners can manage their subscription plans" ON public.subscription_plans
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Subscriptions policies
CREATE POLICY "Users can view their own subscriptions" ON public.subscriptions
  FOR SELECT USING (auth.uid() = student_id OR EXISTS (
    SELECT 1 FROM public.mess_services
    WHERE mess_services.id = subscriptions.mess_id
    AND mess_services.owner_id = auth.uid()
  ));

CREATE POLICY "Users can create their own subscriptions" ON public.subscriptions
  FOR INSERT WITH CHECK (auth.uid() = student_id);

CREATE POLICY "Mess owners can update subscriptions" ON public.subscriptions
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscriptions.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Payments policies
CREATE POLICY "Users can view their own payments" ON public.payments
  FOR SELECT USING (auth.uid() = student_id OR EXISTS (
    SELECT 1 FROM public.mess_services
    WHERE mess_services.id = payments.mess_id
    AND mess_services.owner_id = auth.uid()
  ));

CREATE POLICY "Users can create payments" ON public.payments
  FOR INSERT WITH CHECK (auth.uid() = student_id);

-- Reviews policies
CREATE POLICY "Anyone can view reviews" ON public.reviews
  FOR SELECT USING (true);

CREATE POLICY "Users can create reviews" ON public.reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews" ON public.reviews
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" ON public.reviews
  FOR DELETE USING (auth.uid() = user_id);

-- Menu Items policies
CREATE POLICY "Anyone can view menu items" ON public.menu_items
  FOR SELECT USING (true);

CREATE POLICY "Mess owners can manage their menu items" ON public.menu_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Meal Schedule policies
CREATE POLICY "Anyone can view meal schedules" ON public.meal_schedule
  FOR SELECT USING (true);

CREATE POLICY "Mess owners can manage their meal schedules" ON public.meal_schedule
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Inventory Items policies
CREATE POLICY "Mess owners can view their inventory" ON public.inventory_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "Mess owners can manage their inventory" ON public.inventory_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Announcements policies
CREATE POLICY "Anyone can view announcements" ON public.announcements
  FOR SELECT USING (true);

CREATE POLICY "Mess owners can manage their announcements" ON public.announcements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- INDEXES (for better performance)
-- ============================================

CREATE INDEX IF NOT EXISTS idx_mess_services_owner_id ON public.mess_services(owner_id);
CREATE INDEX IF NOT EXISTS idx_mess_services_location ON public.mess_services(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_subscriptions_student_id ON public.subscriptions(student_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_mess_id ON public.subscriptions(mess_id);
CREATE INDEX IF NOT EXISTS idx_payments_student_id ON public.payments(student_id);
CREATE INDEX IF NOT EXISTS idx_payments_mess_id ON public.payments(mess_id);
CREATE INDEX IF NOT EXISTS idx_reviews_mess_id ON public.reviews(mess_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON public.reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_mess_id ON public.menu_items(mess_id);
CREATE INDEX IF NOT EXISTS idx_meal_schedule_mess_id ON public.meal_schedule(mess_id);

-- ============================================
-- TRIGGERS (for updated_at timestamps)
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to tables with updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mess_services_updated_at BEFORE UPDATE ON public.mess_services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscription_plans_updated_at BEFORE UPDATE ON public.subscription_plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON public.reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_menu_items_updated_at BEFORE UPDATE ON public.menu_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meal_schedule_updated_at BEFORE UPDATE ON public.meal_schedule
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON public.inventory_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.announcements
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();






