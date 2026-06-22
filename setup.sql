CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS wallets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL, icon TEXT DEFAULT '💰',
  balance BIGINT DEFAULT 0, color TEXT DEFAULT '#3B6845',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL, icon TEXT DEFAULT '📦',
  type TEXT CHECK (type IN ('income','expense')) NOT NULL,
  color TEXT DEFAULT '#3B6845'
);
CREATE TABLE IF NOT EXISTS transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_id UUID REFERENCES wallets(id) ON DELETE SET NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  type TEXT CHECK (type IN ('income','expense','transfer')) NOT NULL,
  amount BIGINT NOT NULL, note TEXT,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  job_id UUID, created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS budgets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  month TEXT NOT NULL, amount BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, category_id, month)
);
CREATE TABLE IF NOT EXISTS jobs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL, client TEXT, type TEXT DEFAULT 'main',
  category TEXT DEFAULT 'Khác', amount BIGINT NOT NULL,
  received_date DATE, deadline DATE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','received','cancelled')),
  note TEXT, created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS debts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('lend','borrow')) NOT NULL,
  person TEXT NOT NULL, amount BIGINT NOT NULL,
  paid_amount BIGINT DEFAULT 0, due_date DATE, note TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active','done')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS debt_payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  debt_id UUID REFERENCES debts(id) ON DELETE CASCADE,
  amount BIGINT NOT NULL, note TEXT,
  paid_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own profile" ON profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "own wallets" ON wallets FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own categories" ON categories FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own transactions" ON transactions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own budgets" ON budgets FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own jobs" ON jobs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own debts" ON debts FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own debt_payments" ON debt_payments FOR ALL
  USING (debt_id IN (SELECT id FROM debts WHERE user_id = auth.uid()));
