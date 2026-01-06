-- ============================================
-- Fix Auth Trigger - Recreate with proper syntax
-- ============================================

-- Drop and recreate the function with correct syntax
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
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
  -- SECURITY DEFINER allows this to bypass RLS
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
    COALESCE(NEW.email, ''),
    role_val::user_role,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the user creation
    RAISE WARNING 'Error creating profile for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger on auth.users table
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO postgres, service_role;






