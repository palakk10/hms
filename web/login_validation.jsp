<%@page import="java.sql.*"%>
<%
PreparedStatement ps=null;
ResultSet rs=null;
%>
<%    
    String role=request.getParameter("userrole");
    String email=request.getParameter("email");
    String password=request.getParameter("password");
%>        
<%
    Connection c=(Connection)application.getAttribute("connection");
    if(role.equals("admin"))
    {
        ps=c.prepareStatement("select * from staffinfo where email=? and password=? and desig=?");
        ps.setString(1,email);
        ps.setString(2,password);
        ps.setString(3,role);
        rs=ps.executeQuery();
        if(rs.next())
        {
            String name=rs.getString("NAME");
            session.setAttribute("email",email);
            session.setAttribute("role",role);
            session.setAttribute("name",name);
            response.sendRedirect("admin.jsp");
        }
        else
            response.sendRedirect("login_failed.jsp");
    }
    else if(role.equals("patient"))
    {
        ps=c.prepareStatement("select * from patient_info where email=? and password=?");
        ps.setString(1,email);
        ps.setString(2,password);
        rs=ps.executeQuery();
        if(rs.next())
        {
            String id=String.valueOf(rs.getInt("ID"));
            String name=rs.getString("PNAME");
            int doctorId = rs.getInt("DOCTOR_ID");
            
            // Get doctor's name
            PreparedStatement psDoctor = c.prepareStatement("SELECT NAME FROM doctor_info WHERE ID = ?");
            psDoctor.setInt(1, doctorId);
            ResultSet rsDoctor = psDoctor.executeQuery();
            String doctorName = "";
            if(rsDoctor.next()) {
                doctorName = rsDoctor.getString("NAME");
            }
            rsDoctor.close();
            psDoctor.close();
            
            session.setAttribute("id",id);
            session.setAttribute("email",email);
            session.setAttribute("role",role);
            session.setAttribute("name",name);
            session.setAttribute("doc",doctorName);
            response.sendRedirect("patient_page.jsp");
        }
        else
            response.sendRedirect("login_failed.jsp");
    }
    else if(role.equals("doctor"))
    {
        ps=c.prepareStatement("select * from doctor_info where email=? and password=?");
        ps.setString(1,email);
        ps.setString(2,password);
        rs=ps.executeQuery();
        if(rs.next())
        {
            String id=String.valueOf(rs.getInt("ID"));
            String name=rs.getString("NAME");
            int deptId = rs.getInt("DEPT_ID");
            
            // Get department name
            PreparedStatement psDept = c.prepareStatement("SELECT NAME FROM department WHERE ID = ?");
            psDept.setInt(1, deptId);
            ResultSet rsDept = psDept.executeQuery();
            String deptName = "";
            if(rsDept.next()) {
                deptName = rsDept.getString("NAME");
            }
            rsDept.close();
            psDept.close();
            
            session.setAttribute("id",id);
            session.setAttribute("email",email);
            session.setAttribute("role",role);
            session.setAttribute("name",name);
            session.setAttribute("dept",deptName);
            response.sendRedirect("doctor_page.jsp");
        }
        else
            response.sendRedirect("login_failed.jsp");
    }
    else
    {
        response.sendRedirect("login_failed.jsp");
    }
    
    if(rs != null) rs.close();
    if(ps != null) ps.close();
%>