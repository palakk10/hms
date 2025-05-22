import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.DriverManager;
import javax.servlet.ServletContextListener;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
public class ConnectionDao implements ServletContextListener
{
	public void contextInitialized(ServletContextEvent e)
	{
		try
		{
			Class.forName("com.mysql.cj.jdbc.Driver");
			Connection c=DriverManager.getConnection("jdbc:mysql://localhost:3306/hms","root","Naman@123");
			c.setHoldability(ResultSet.CLOSE_CURSORS_AT_COMMIT); 
			ServletContext ctx=e.getServletContext();
			ctx.setAttribute("connection",c);
		}	
		catch(Exception ee){ee.printStackTrace();}
	}
	public void contextDestroyed(ServletContextEvent e)
	{}
}