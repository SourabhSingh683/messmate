-- ============================================
-- Fix Subscription Plans RLS - Ensure INSERT works
-- ============================================

-- Drop existing subscription plan policies
DROP POLICY IF EXISTS "mess_owners_insert_subscription_plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "mess_owners_update_subscription_plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "mess_owners_delete_subscription_plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can insert subscription plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can update subscription plans" ON public.subscription_plans;
DROP POLICY IF EXISTS "Mess owners can delete subscription plans" ON public.subscription_plans;

-- Recreate with proper permissions
CREATE POLICY "subscription_plans_insert" ON public.subscription_plans
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

CREATE POLICY "subscription_plans_update" ON public.subscription_plans
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

CREATE POLICY "subscription_plans_delete" ON public.subscription_plans
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM public.mess_services
      WHERE mess_services.id = subscription_plans.mess_id
      AND mess_services.owner_id = auth.uid()
    )
  );

-- Verify the policies exist
DO $$
BEGIN
  RAISE NOTICE 'Subscription plans policies created successfully';
END $$;






