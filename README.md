# 🚀 Contoso Database Setup Guide

A comprehensive guide to setting up the Contoso database with sample data for analysis and testing.

---

## 📋 Prerequisites

Before you begin, ensure you have:
- PostgreSQL installed on your system
- Git installed (to clone the repository)
- At least 2GB of free disk space
- 7-Zip or similar tool to extract `.7z` archives

---

## 🔧 Step 1: Add PostgreSQL to Environment Variables

### Windows

1. **Locate your PostgreSQL bin directory**
   - Default location: `C:\Program Files\PostgreSQL\<version>\bin`

2. **Add to PATH**
   - Right-click on **This PC** or **My Computer** → **Properties**
   - Click **Advanced system settings** → **Environment Variables**
   - Under **System variables**, find and select **Path** → Click **Edit**
   - Click **New** and add your PostgreSQL bin path
   - Click **OK** on all windows to save

3. **Verify installation**
   ```powershell
   psql --version
   ```

### macOS

1. **Add to PATH** (if installed via Homebrew)
   ```bash
   echo 'export PATH="/Library/PostgreSQL/18/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **For Postgres.app users**
   ```bash
   echo 'export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Verify installation**
   ```bash
   psql --version
   ```

---

## 📥 Step 2: Clone the Repository

```bash
git clone https://github.com/muhssamy/Contoso-Analytics.git
cd Contoso-Analytics
```

---

## 💾 Step 3: Download and Extract CSV Files

1. **Download the dataset**
   
   Download the CSV files from the official release:
   ```
   https://github.com/sql-bi/Contoso-Data-Generator-V2-Data/releases/download/ready-to-use-data/csv-10m.7z
   ```

2. **Extract the archive**
   
   Extract the `.7z` file using 7-Zip or your preferred extraction tool

3. **Move CSV files to the project**
   
   ⚠️ **Important**: Copy only the `.csv` files (not the folder) into your project's `csv-10m` directory
   
   ```
   your-project/
   └── csv-10m/
       ├── customers.csv
       ├── products.csv
       ├── sales.csv
       ├── contoso_load.sql
       └── ... (other CSV files)
   ```

---

## 🗄️ Step 4: Create the Contoso Database

Run the following command to create a new database:

```powershell
psql -U postgres -c "CREATE DATABASE contoso;"
```

You'll be prompted for your PostgreSQL password.

---

## 📊 Step 5: Load the Data

Execute the SQL script to import all CSV data into the database:

```powershell
psql -U postgres -d contoso -f csv-10m/contoso_load.sql
```

This process may take several minutes depending on your system specifications and the size of the dataset.

---

## ✅ Verification

After loading, verify your setup:

```sql
-- Connect to the database
psql -U postgres -d contoso

-- Check tables
\dt

-- Check row counts
SELECT 
    schemaname,
    tablename,
    n_live_tup as row_count
FROM pg_stat_user_tables
ORDER BY n_live_tup DESC;
```

---

## 🎯 Next Steps

Your Contoso database is now ready! You can:
- Run analytical queries
- Build dashboards and reports
- Practice SQL skills
- Test ETL pipelines

---

## 🐛 Troubleshooting

**Issue**: `psql` command not found
- **Solution**: Ensure PostgreSQL bin directory is properly added to PATH and restart your terminal

**Issue**: Permission denied when creating database
- **Solution**: Make sure you're using a PostgreSQL superuser account (default: `postgres`)

**Issue**: CSV files not loading
- **Solution**: Verify that CSV files are directly in the `csv-10m` folder, not in a subfolder

---

## 📚 Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Contoso Data Generator](https://github.com/sql-bi/Contoso-Data-Generator-V2-Data)

---

**Happy Querying! 🎉**
