-- ============================================
-- Fix RLS Policies for Mess Owner Operations
-- This fixes INSERT operations for subscription plans, menu items, etc.
-- ============================================

-- Drop existing policies that need fixing
DROP POLICY IF EXISTS "Mess owners can manage their subscription plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can manage their menu items" ON public.menu_items;
DROP POLICY IF EXISTS "Mess owners can manage their meal schedules" ON public.meal_schedule;
DROP POLICY IF EXISTS "Mess owners can manage their inventory" ON public.inventory_items;
DROP POLICY IF EXISTS "Mess owners can manage their announcements" ON public.announcements;
DROP POLICY IF EXISTS "Mess owners can manage their mess images" ON public.mess_images;

-- ============================================
-- Subscription Plans - Fixed Policies
-- ============================================

-- SELECT: Anyone can view
-- (Already exists, keeping it)

-- INSERT: Mess owners can create plans for their mess
CREATE POLICY "Mess owners can insert subscription plans" ON public.subscription_plans
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- UPDATE: Mess owners can update their plans
CREATE POLICY "Mess owners can update subscription plans" ON public.subscription_plans
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- DELETE: Mess owners can delete their plans
CREATE POLICY "Mess owners can delete subscription plans" ON public.subscription_plans
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Menu Items - Fixed Policies
-- ============================================

-- INSERT: Mess owners can create menu items
CREATE POLICY "Mess owners can insert menu items" ON public.menu_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- UPDATE: Mess owners can update their menu items
CREATE POLICY "Mess owners can update menu items" ON public.menu_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- DELETE: Mess owners can delete their menu items
CREATE POLICY "Mess owners can delete menu items" ON public.menu_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Meal Schedule - Fixed Policies
-- ============================================

-- INSERT: Mess owners can create meal schedules
CREATE POLICY "Mess owners can insert meal schedules" ON public.meal_schedule
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- UPDATE: Mess owners can update their meal schedules
CREATE POLICY "Mess owners can update meal schedules" ON public.meal_schedule
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- DELETE: Mess owners can delete their meal schedules
CREATE POLICY "Mess owners can delete meal schedules" ON public.meal_schedule
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Inventory Items - Fixed Policies
-- ============================================

-- INSERT: Mess owners can create inventory items
CREATE POLICY "Mess owners can insert inventory items" ON public.inventory_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- UPDATE: Mess owners can update their inventory items
CREATE POLICY "Mess owners can update inventory items" ON public.inventory_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- DELETE: Mess owners can delete their inventory items
CREATE POLICY "Mess owners can delete inventory items" ON public.inventory_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Announcements - Fixed Policies
-- ============================================

-- INSERT: Mess owners can create announcements
CREATE POLICY "Mess owners can insert announcements" ON public.announcements
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- UPDATE: Mess owners can update their announcements
CREATE POLICY "Mess owners can update announcements" ON public.announcements
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- DELETE: Mess owners can delete their announcements
CREATE POLICY "Mess owners can delete announcements" ON public.announcements
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Mess Images - Fixed Policies
-- ============================================

-- INSERT: Mess owners can create mess images
CREATE POLICY "Mess owners can insert mess images" ON public.mess_images
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- UPDATE: Mess owners can update their mess images
CREATE POLICY "Mess owners can update mess images" ON public.mess_images
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- DELETE: Mess owners can delete their mess images
CREATE POLICY "Mess owners can delete mess images" ON public.mess_images
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Customer Management - Allow Mess Owners to Create Customer Profiles
-- ============================================

-- Mess owners need to create customer profiles, but the current policy only allows
-- users to insert their own profile. We'll use the existing create_customer_profile
-- function which uses SECURITY DEFINER, but we also need a policy for direct inserts
-- when using the function.

-- Note: The create_customer_profile function already handles this with SECURITY DEFINER,
-- but we should also allow mess owners to insert customer profiles directly if needed.
-- However, since the function is used, this might not be necessary, but let's add it
-- for flexibility.

-- Allow mess owners to insert customer profiles (for customers they're adding)
-- This is a special case - we'll check if the mess owner is trying to add a customer
-- by verifying they own a mess service. The actual customer profile creation should
-- use the create_customer_profile function, but this policy provides a fallback.

-- Actually, let's keep the existing profile policy and rely on the create_customer_profile
-- function which uses SECURITY DEFINER to bypass RLS. The function is already set up correctly.

-- ============================================
-- Subscriptions - Allow Mess Owners to Create Subscriptions for Customers
-- ============================================

-- Add policy for mess owners to create subscriptions when adding customers
CREATE POLICY "Mess owners can create subscriptions for their mess" ON public.subscriptions
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscriptions.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Payments - Allow Mess Owners to View All Payments for Their Mess
-- ============================================

-- The existing policy already allows mess owners to view payments for their mess
-- (line 358-363 in the original migration), so this is already covered.






