-- ============================================
-- Make profiles usable for manual customers
-- ============================================
-- The FK to auth.users prevents inserting customer profiles
-- that don't have an auth account. We drop the FK and allow
-- the app to manage linkages explicitly.

-- Drop FK constraint
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- Ensure id has a default UUID (for manual inserts)
ALTER TABLE public.profiles
  ALTER COLUMN id SET DEFAULT uuid_generate_v4();

-- (Optional) Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_id ON public.profiles(id);

