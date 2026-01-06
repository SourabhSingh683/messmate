-- ============================================
-- Auth Trigger for Auto-Creating Profiles
-- This trigger automatically creates a profile
-- when a new user signs up
-- ============================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  first_name_val TEXT;
  last_name_val TEXT;
  role_val TEXT;
BEGIN
  -- Get metadata from auth.users.raw_user_meta_data
  first_name_val := COALESCE(NEW.raw_user_meta_data->>'first_name', '');
  last_name_val := COALESCE(NEW.raw_user_meta_data->>'last_name', '');
  role_val := COALESCE(NEW.raw_user_meta_data->>'role', 'student');
  
  -- Insert into profiles table
  INSERT INTO public.profiles (
    id,
    first_name,
    last_name,
    email,
    role,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    first_name_val,
    last_name_val,
    NEW.email,
    role_val::user_role,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on auth.users table (only if it doesn't exist)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'on_auth_user_created'
  ) THEN
    CREATE TRIGGER on_auth_user_created
      AFTER INSERT ON auth.users
      FOR EACH ROW
      EXECUTE FUNCTION public.handle_new_user();
  END IF;
END $$;

-- ============================================
-- Grant necessary permissions
-- ============================================

-- Allow the trigger function to insert into profiles
-- SECURITY DEFINER functions run with the privileges of the function owner
-- So we need to ensure the function owner (postgres) has INSERT permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT INSERT ON public.profiles TO postgres, service_role;

-- Ensure the function can bypass RLS (SECURITY DEFINER already does this, but let's be explicit)
ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

