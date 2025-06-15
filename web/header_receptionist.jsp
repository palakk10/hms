<%@page import="javax.servlet.http.HttpSession"%>
<%
    String name = (String) session.getAttribute("name");
    if (name == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<div class="header">
    <div class="row">
        <div class="col-md-10">
            <h2>Hospital Management System</h2>
        </div>
        <div class="col-md-2">
            <ul class="nav nav-pills">
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button"><%=name.toUpperCase()%> <span class="caret"></span></a>
                    <ul class="dropdown-menu">
                        <li><a href="profile_receptionist.jsp">Change Profile</a></li>
                        <li role="separator" class="divider"></li>
                        <li><a href="logout.jsp">Logout</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</div>