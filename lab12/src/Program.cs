using System;
using System.Configuration;
using System.Data.Common;
using System.Data;

class Program
{
    static void Main()
    {
        DbProviderFactories.RegisterFactory("System.Data.SqlClient", System.Data.SqlClient.SqlClientFactory.Instance);

        string connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

        DbProviderFactory df = DbProviderFactories.GetFactory(ConfigurationManager.ConnectionStrings["DefaultConnection"].ProviderName);

        Console.WriteLine($"Connection String: {connectionString}");
        Console.WriteLine($"Provider Name: {df.GetType().FullName}");


        DbConnection cn = df.CreateConnection();
        
        cn.ConnectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        cn.Open();


        // DbDataReader dr = SelectUsers(df, cn); 
        // 
        // while (dr.Read()) {
        //   for (int i = 0; i < dr.FieldCount; i++) {
        //     string columnName = dr.GetName(i);
        //     object columnValue = dr.GetValue(i);
        //
        //     Console.Write($"{columnName}: {columnValue} ;");
        //   }
        //   Console.WriteLine("");
        // }
        // dr.Close();


        // InsertNewUser(df, cn, "ado@ado.ru", "ado_name", "ado_surname", "ado_nickname");
        // DeleteUser(df, cn, 3);
        // UpdateUserName(df, cn, 1, "new_name123");
        
        // InsertNewQuestion(df, cn, "title_ado", "description_ado", 1);
        // DeleteQuestion(df, cn, 2);
        // UpdateQuestionTitle(df, cn, 1, "new title");
        // UpdateQuestionDescription(df, cn, 1, "new description");

        InsertNewQuestion(df, cn, "title", "description", 1);
        DeleteUser(df, cn, 12);
        
        DbDataReader dr = SelectQuestions(df, cn); 

        PrintTable(dr); 
        
        Console.WriteLine("");

        dr.Close();

        
        TestConnected(df, cn);
        
        dr = SelectUsers(df, cn); 

        PrintTable(dr);


        dr.Close();

        dr = SelectQuestions(df, cn); 
        Console.WriteLine("");

        PrintTable(dr);
       
        dr.Close();

    }

    static void PrintTable(DbDataReader dr) {
      while (dr.Read()) {
          for (int i = 0; i < dr.FieldCount; i++) {
            string columnName = dr.GetName(i);
            object columnValue = dr.GetValue(i);

            Console.Write($"{columnName}: {columnValue}; ");
          }
          Console.WriteLine("");
        }
    }


    static void TestConnected(DbProviderFactory df, DbConnection cn) {

      // Inert New User
     using (DbCommand cmd = df.CreateCommand())
      {
        cmd.Connection = cn;
        cmd.CommandText = "INSERT INTO Users (email, nickname, name, surname) VALUES ('Newemail@mail.ru', 'new_nickname', 'new_name', 'new_surname')";
        cmd.ExecuteNonQuery();
      }


     // Update User
     using (DbCommand cmd = df.CreateCommand())
      {
        cmd.Connection = cn;
        cmd.CommandText = "UPDATE Users SET name = 'new name for 1', surname = 'new surname for 1' WHERE user_id = 1";
        cmd.ExecuteNonQuery();
      }


      // Delete question 
     using (DbCommand cmd = df.CreateCommand())
      {
        cmd.Connection = cn;
        cmd.CommandText = "DELETE FROM Questions WHERE title LIKE '%title'";
        cmd.ExecuteNonQuery();
      }
    }

    static DbDataReader SelectUsers(DbProviderFactory df, DbConnection cn) {
      using (DbCommand cmd = df.CreateCommand())
      {
        cmd.Connection = cn;
        cmd.CommandText = "SELECT * FROM Users";
      
        DbDataReader dr = cmd.ExecuteReader();

        return dr;
      
      }
    } 

    static void InsertNewUser(DbProviderFactory df, DbConnection cn, string email, string name, string surname, string nickname) {
      using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "INSERT INTO Users (email, nickname, name, surname) VALUES (@Email, @Nickname, @Name, @Surname)";

            DbParameter nameParam = cmd.CreateParameter();
            nameParam.ParameterName = "@Name";
            nameParam.Value = name;
            cmd.Parameters.Add(nameParam);
            
            DbParameter surnameParam = cmd.CreateParameter();
            surnameParam.ParameterName = "@Surname";
            surnameParam.Value = name;
            cmd.Parameters.Add(surnameParam);
            
 
            DbParameter emailParam = cmd.CreateParameter();
            emailParam.ParameterName = "@Email";
            emailParam.Value = email;
            cmd.Parameters.Add(emailParam);

            DbParameter nicknameParam = cmd.CreateParameter();
            nicknameParam .ParameterName = "@Nickname";
            nicknameParam.Value = nickname;
            cmd.Parameters.Add(nicknameParam);

            try
            {
                cmd.ExecuteNonQuery();
                Console.WriteLine("New user inserted successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error inserting user: {ex.Message}");
            }
        }
    }


    static void UpdateUserName(DbProviderFactory df, DbConnection cn, int userID, string name) {
       using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "UPDATE Users SET name = @Name WHERE user_id = @UserID";

            DbParameter userIDParam = cmd.CreateParameter();
            userIDParam.ParameterName = "@UserID";
            userIDParam.Value = userID;
            cmd.Parameters.Add(userIDParam);
            
            DbParameter nameParam = cmd.CreateParameter();
            nameParam.ParameterName = "@Name";
            nameParam.Value = name;
            cmd.Parameters.Add(nameParam);
            
            try
            {
              cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating user name: {ex.Message}");
            }
        }

      
    }
    static void UpdateUserSurname(DbProviderFactory df, DbConnection cn, int userID, string surname) {
         using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "UPDATE Users SET name = @Name WHERE user_id = @UserID";

            DbParameter userIDParam = cmd.CreateParameter();
            userIDParam.ParameterName = "@UserID";
            userIDParam.Value = userID;
            cmd.Parameters.Add(userIDParam);
            
            DbParameter surnameParam = cmd.CreateParameter();
            surnameParam.ParameterName = "@Surname";
            surnameParam.Value = surname;
            cmd.Parameters.Add(surnameParam);
            
            try
            {
              cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating user surname: {ex.Message}");
            }
        }


      
    }
    
    static void UpdateUserNickname(DbProviderFactory df, DbConnection cn, int userID, string nickname) {
        using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "UPDATE Users SET nickname = @Nickame WHERE user_id = @UserID";

            DbParameter userIDParam = cmd.CreateParameter();
            userIDParam.ParameterName = "@UserID";
            userIDParam.Value = userID;
            cmd.Parameters.Add(userIDParam);
            
            DbParameter nicknameParam = cmd.CreateParameter();
            nicknameParam.ParameterName = "@Nickname";
            nicknameParam.Value = nickname;
            cmd.Parameters.Add(nicknameParam);
            
            try
            {
              cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating user nickname: {ex.Message}");
            }
        }
    }
    
    static void UpdateUserEmail(DbProviderFactory df, DbConnection cn, int userID, string name, string surname, string email) {
      using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "UPDATE Users SET email = @Email WHERE user_id = @UserID";

            DbParameter userIDParam = cmd.CreateParameter();
            userIDParam.ParameterName = "@UserID";
            userIDParam.Value = userID;
            cmd.Parameters.Add(userIDParam);
            
            DbParameter emailParam = cmd.CreateParameter();
            emailParam.ParameterName = "@Email";
            emailParam.Value = email;
            cmd.Parameters.Add(emailParam);
            
            try
            {
              cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating user email: {ex.Message}");
            }
        }


    }
    
    static void DeleteUser(DbProviderFactory df, DbConnection cn, int userID) {
        using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "DELETE FROM Users WHERE user_id = @UserID";

            DbParameter userIDParam = cmd.CreateParameter();
            userIDParam.ParameterName = "@UserID";
            userIDParam.Value = userID;

            cmd.Parameters.Add(userIDParam);

            try
            {
                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    Console.WriteLine($"User with user_id = '{userID}' deleted successfully.");
                }
                else
                {
                    Console.WriteLine($"No users found for user_id = '{userID}'.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting user: {ex.Message}");
            }
    }
  }



  static DbDataReader SelectQuestions(DbProviderFactory df, DbConnection cn) {
      using (DbCommand cmd = df.CreateCommand())
      {
        cmd.Connection = cn;
        cmd.CommandText = "SELECT * FROM Questions";
      
        DbDataReader dr = cmd.ExecuteReader();

        return dr;
      
      }
  }


  static void UpdateQuestionTitle(DbProviderFactory df, DbConnection cn, int questionID, string title) {
      using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "UPDATE Questions SET title = @Title WHERE question_num = @QuestionID";

            DbParameter questionIDParam = cmd.CreateParameter();
            questionIDParam.ParameterName = "@QuestionID";
            questionIDParam.Value = questionID;
            cmd.Parameters.Add(questionIDParam);
            
            DbParameter titleParam = cmd.CreateParameter();
            titleParam.ParameterName = "@Title";
            titleParam.Value = title;
            cmd.Parameters.Add(titleParam);
            
            try
            {
              cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating question title: {ex.Message}");
            }
        }


    }
   

  static void UpdateQuestionDescription(DbProviderFactory df, DbConnection cn, int questionID, string description) {
      using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "UPDATE Questions SET description = @Description WHERE question_num = @QuestionID";

            DbParameter questionIDParam = cmd.CreateParameter();
            questionIDParam.ParameterName = "@QuestionID";
            questionIDParam.Value = questionID;
            cmd.Parameters.Add(questionIDParam);
            
            DbParameter descriptionParam = cmd.CreateParameter();
            descriptionParam.ParameterName = "@Description";
            descriptionParam.Value = description;
            cmd.Parameters.Add(descriptionParam);
            
            try
            {
              cmd.ExecuteNonQuery();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating question description: {ex.Message}");
            }
        }


    }
 
  

  static void InsertNewQuestion(DbProviderFactory df, DbConnection cn, string title, string description, int userID) {
      using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "INSERT INTO Questions (title, description, user_id) VALUES (@Title, @Description, @UserID)";

            DbParameter titleParam = cmd.CreateParameter();
            titleParam.ParameterName = "@Title";
            titleParam.Value = title;
            cmd.Parameters.Add(titleParam);
            
            DbParameter descriptionParam = cmd.CreateParameter();
            descriptionParam.ParameterName = "@Description";
            descriptionParam.Value = description;
            cmd.Parameters.Add(descriptionParam);
            
 
            DbParameter userIDParam = cmd.CreateParameter();
            userIDParam.ParameterName = "@UserID";
            userIDParam.Value = userID;
            cmd.Parameters.Add(userIDParam);

            try
            {
                cmd.ExecuteNonQuery();
                Console.WriteLine("New question inserted successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error inserting question: {ex.Message}");
            }
        }
  }


    
  static void DeleteQuestion(DbProviderFactory df, DbConnection cn, int questionID) {
        using (DbCommand cmd = df.CreateCommand())
        {
            cmd.Connection = cn;

            cmd.CommandText = "DELETE FROM Questions WHERE question_num = @QuestionID";

            DbParameter questionIDParam = cmd.CreateParameter();
            questionIDParam.ParameterName = "@QuestionID";
            questionIDParam.Value = questionID;

            cmd.Parameters.Add(questionIDParam);

            try
            {
                int rowsAffected = cmd.ExecuteNonQuery();

                if (rowsAffected > 0)
                {
                    Console.WriteLine($"Question with question_num = '{questionID}' deleted successfully.");
                }
                else
                {
                    Console.WriteLine($"No question found for question_id = '{questionID}'.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting question: {ex.Message}");
            }
    }
  }

}

