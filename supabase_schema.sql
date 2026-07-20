                                                    -- SQL SCHEMA FOR SUPABASE
                                                    -- Run this in the Supabase SQL Editor

                                                    -- 1. PROFILES TABLE
                                                    CREATE TABLE profiles (
                                                      id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
                                                      full_name TEXT,
                                                      preferred_country TEXT,
                                                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                                                    );

                                                    -- Enable RLS
                                                    ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

                                                    -- Policies
                                                    CREATE POLICY "Users can view their own profile" ON profiles
                                                      FOR SELECT USING (auth.uid() = id);

                                                    CREATE POLICY "Users can update their own profile" ON profiles
                                                      FOR UPDATE USING (auth.uid() = id);

                                                    CREATE POLICY "Users can insert their own profile" ON profiles
                                                      FOR INSERT WITH CHECK (auth.uid() = id);

                                                    -- 2. ZAKAT HISTORY TABLE
                                                    CREATE TABLE zakat_history (
                                                      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                                      user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
                                                      total_assets NUMERIC NOT NULL,
                                                      total_liabilities NUMERIC NOT NULL,
                                                      net_wealth NUMERIC NOT NULL,
                                                      zakat_due NUMERIC NOT NULL,
                                                      currency TEXT NOT NULL,
                                                      calculation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                                                      details JSONB NOT NULL
                                                    );

                                                    -- Enable RLS
                                                    ALTER TABLE zakat_history ENABLE ROW LEVEL SECURITY;

                                                    -- Policies
                                                    CREATE POLICY "Users can view their own history" ON zakat_history
                                                      FOR SELECT USING (auth.uid() = user_id);

                                                    CREATE POLICY "Users can insert their own history" ON zakat_history
                                                      FOR INSERT WITH CHECK (auth.uid() = user_id);

                                                    -- 3. TRIGGER FOR PROFILE CREATION ON SIGNUP
                                                    CREATE OR REPLACE FUNCTION public.handle_new_user()
                                                    RETURNS TRIGGER AS $$
                                                    BEGIN
                                                      INSERT INTO public.profiles (id, full_name)
                                                      VALUES (new.id, new.raw_user_meta_data->>'full_name');
                                                      RETURN NEW;
                                                    END;
                                                    $$ LANGUAGE plpgsql SECURITY DEFINER;

                                                    CREATE TRIGGER on_auth_user_created
                                                      AFTER INSERT ON auth.users
                                                      FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
