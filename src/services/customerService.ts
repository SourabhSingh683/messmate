import { supabase } from '@/integrations/supabase/client';
import { fetchFromSupabase } from '@/utils/supabaseRawApi';

export interface Customer {
  id: string;
  student_id: string;
  first_name: string;
  last_name: string;
  created_at: string;
  mess_id: string;
  subscription_status: string;
  address?: string;
  mobile?: string;
  email?: string;
}

export const fetchCustomers = async (messId: string): Promise<Customer[]> => {
  const { data, error } = await supabase
    .from('subscriptions')
    .select(`
      id,
      student_id,
      mess_id,
      status,
      created_at,
      profiles:student_id(
        first_name,
        last_name,
        avatar_url,
        address,
        mobile,
        email
      )
    `)
    .eq('mess_id', messId);

  if (error) {
    console.error('Error fetching customers:', error);
    throw error;
  }

  if (!data) {
    return [];
  }

  return data.map((item) => ({
    id: item.id,
    student_id: item.student_id,
    first_name: item.profiles?.first_name || 'Unknown',
    last_name: item.profiles?.last_name || 'Unknown',
    created_at: item.created_at || new Date().toISOString(),
    mess_id: item.mess_id,
    subscription_status: item.status,
    address: item.profiles?.address,
    mobile: item.profiles?.mobile,
    email: item.profiles?.email,
  }));
};

export const addCustomer = async (
  messId: string, 
  firstName: string, 
  lastName: string,
  address: string,
  mobile: string,
  email?: string
): Promise<void> => {
  try {
    // 1. Generate a unique ID for the customer
    const customerId = crypto.randomUUID();

    // 2. Insert into profiles
    const { error: profileError } = await supabase
      .from('profiles')
      .insert({
        id: customerId,
        first_name: firstName,
        last_name: lastName,
        address,
        mobile,
        email,
        role: 'student'
      });

    if (profileError) throw profileError;

    // 3. Insert into subscriptions
    const { error: subscriptionError } = await supabase
      .from('subscriptions')
      .insert({
        student_id: customerId,
        mess_id: messId,
        status: 'active',
        start_date: new Date().toISOString().split('T')[0],
        end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      });

    if (subscriptionError) throw subscriptionError;

    console.log('Customer added successfully with ID:', customerId);
  } catch (error: any) {
    console.error('Error in addCustomer:', error);
    throw new Error(error.message || 'Failed to create customer');
  }
};

export const deleteCustomer = async (customerId: string): Promise<void> => {
  const { error } = await supabase
    .from('subscriptions')
    .delete()
    .eq('id', customerId);

  if (error) throw error;
};
