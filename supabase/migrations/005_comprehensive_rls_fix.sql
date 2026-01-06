-- ============================================
-- Comprehensive RLS Policy Fix
-- This drops ALL existing policies and recreates them properly
-- ============================================

-- ============================================
-- Drop ALL existing policies for these tables
-- ============================================

-- Subscription Plans
DROP POLICY IF EXISTS "Mess owners can manage their subscription plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can insert subscription plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can update subscription plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can delete subscription plans" ON public.subscription_plans;

-- Menu Items
DROP POLICY IF EXISTS "Mess owners can manage their menu items" ON public.menu_items;
DROP POLICY IF EXISTS "Mess owners can insert menu items" ON public.menu_items;
DROP POLICY IF EXISTS "Mess owners can update menu items" ON public.menu_items;
DROP POLICY IF EXISTS "Mess owners can delete menu items" ON public.menu_items;

-- Meal Schedule
DROP POLICY IF EXISTS "Mess owners can manage their meal schedules" ON public.meal_schedule;
DROP POLICY IF EXISTS "Mess owners can insert meal schedules" ON public.meal_schedule;
DROP POLICY IF EXISTS "Mess owners can update meal schedules" ON public.meal_schedule;
DROP POLICY IF EXISTS "Mess owners can delete meal schedules" ON public.meal_schedule;

-- Inventory Items
DROP POLICY IF EXISTS "Mess owners can manage their inventory" ON public.inventory_items;
DROP POLICY IF EXISTS "Mess owners can insert inventory items" ON public.inventory_items;
DROP POLICY IF EXISTS "Mess owners can update inventory items" ON public.inventory_items;
DROP POLICY IF EXISTS "Mess owners can delete inventory items" ON public.inventory_items;

-- Announcements
DROP POLICY IF EXISTS "Mess owners can manage their announcements" ON public.announcements;
DROP POLICY IF EXISTS "Mess owners can insert announcements" ON public.announcements;
DROP POLICY IF EXISTS "Mess owners can update announcements" ON public.announcements;
DROP POLICY IF EXISTS "Mess owners can delete announcements" ON public.announcements;

-- Mess Images
DROP POLICY IF EXISTS "Mess owners can manage their mess images" ON public.mess_images;
DROP POLICY IF EXISTS "Mess owners can insert mess images" ON public.mess_images;
DROP POLICY IF EXISTS "Mess owners can update mess images" ON public.mess_images;
DROP POLICY IF EXISTS "Mess owners can delete mess images" ON public.mess_images;

-- ============================================
-- Subscription Plans - Recreate Policies
-- ============================================

CREATE POLICY "mess_owners_insert_subscription_plans" ON public.subscription_plans
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_update_subscription_plans" ON public.subscription_plans
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_delete_subscription_plans" ON public.subscription_plans
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Menu Items - Recreate Policies
-- ============================================

CREATE POLICY "mess_owners_insert_menu_items" ON public.menu_items
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_update_menu_items" ON public.menu_items
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_delete_menu_items" ON public.menu_items
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = menu_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Meal Schedule - Recreate Policies
-- ============================================

CREATE POLICY "mess_owners_insert_meal_schedule" ON public.meal_schedule
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_update_meal_schedule" ON public.meal_schedule
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_delete_meal_schedule" ON public.meal_schedule
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = meal_schedule.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Inventory Items - Recreate Policies
-- ============================================

CREATE POLICY "mess_owners_insert_inventory_items" ON public.inventory_items
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_update_inventory_items" ON public.inventory_items
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_delete_inventory_items" ON public.inventory_items
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = inventory_items.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Announcements - Recreate Policies
-- ============================================

CREATE POLICY "mess_owners_insert_announcements" ON public.announcements
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_update_announcements" ON public.announcements
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_delete_announcements" ON public.announcements
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = announcements.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Mess Images - Recreate Policies
-- ============================================

CREATE POLICY "mess_owners_insert_mess_images" ON public.mess_images
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_update_mess_images" ON public.mess_images
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "mess_owners_delete_mess_images" ON public.mess_images
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = mess_images.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- ============================================
-- Subscriptions - Add INSERT policy for mess owners
-- ============================================

-- Check if policy already exists, if not create it
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'subscriptions' 
    AND policyname = 'mess_owners_insert_subscriptions'
  ) THEN
    CREATE POLICY "mess_owners_insert_subscriptions" ON public.subscriptions
      FOR INSERT 
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.mess_services
          WHERE mess_services.id = subscriptions.mess_id
          AND mess_services.owner_id = auth.uid()
        )
      );
  END IF;
END $$;






