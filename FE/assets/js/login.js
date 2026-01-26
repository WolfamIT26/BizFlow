// Login page JS (scoped)
const API_BASE = '/api';
const ALLOWED_ROLES = ['ADMIN','OWNER','EMPLOYEE', 'MANAGER'];
const ROLE_PREFIX = 'ROLE_';

function showLoginError(message){
  const el=document.getElementById('loginError');
  if(el){el.textContent=message;el.style.display='block';}
}

function redirectByRole(role){
  switch(role){
    case 'ADMIN': window.location.href='/admin/admin-dashboard.html'; break;
    case 'OWNER': window.location.href='/pages/owner-dashboard.html'; break;
    case 'MANAGER': window.location.href='/pages/dashboard.html'; break;
    case 'EMPLOYEE': window.location.href='/pages/employee-dashboard.html'; break;
    default: showLoginError('Bạn không có quyền truy cập ứng dụng này. Vui lòng kiểm tra lại.');
  }
}

window.addEventListener('DOMContentLoaded',()=>{
  const storedToken = sessionStorage.getItem('accessToken') || localStorage.getItem('accessToken');
  const storedRole = sessionStorage.getItem('role') || localStorage.getItem('role');
  const normalizedRole = normalizeRole(storedRole);
  if(storedToken && normalizedRole && ALLOWED_ROLES.includes(normalizedRole)){
    sessionStorage.setItem('accessToken', storedToken);
    sessionStorage.setItem('role', normalizedRole);
    if (localStorage.getItem('username')) {
      sessionStorage.setItem('username', localStorage.getItem('username'));
    }
    if (localStorage.getItem('userId')) {
      sessionStorage.setItem('userId', localStorage.getItem('userId'));
    }
    redirectByRole(normalizedRole);
  } else if (storedToken && (!normalizedRole || !ALLOWED_ROLES.includes(normalizedRole))) {
    sessionStorage.clear();
    localStorage.removeItem('accessToken');
    localStorage.removeItem('username');
    localStorage.removeItem('role');
    localStorage.removeItem('userId');
  }

  // Toggle password visibility
  const togglePasswordBtn = document.getElementById('togglePassword');
  const passwordInput = document.getElementById('password');
  const eyeIcon = document.querySelector('.eye-icon');
  const eyeSlashIcon = document.querySelector('.eye-slash-icon');
  
  if(togglePasswordBtn && passwordInput) {
    togglePasswordBtn.addEventListener('click', (e) => {
      e.preventDefault();
      const isPassword = passwordInput.type === 'password';
      passwordInput.type = isPassword ? 'text' : 'password';
      eyeIcon.style.display = isPassword ? 'none' : 'block';
      eyeSlashIcon.style.display = isPassword ? 'block' : 'none';
    });
  }

  const form=document.getElementById('loginForm');
  if(form){
    form.addEventListener('submit',async(e)=>{
      e.preventDefault();
      const username=document.getElementById('username').value.trim();
      const password=document.getElementById('password').value.trim();
      if(!username||!password){showLoginError('Vui lòng nhập đầy đủ thông tin');return;}
      try{
        const res=await fetch(`${API_BASE}/auth/login`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({username,password})});
        if(res.ok){
          const data=await res.json();
          sessionStorage.setItem('accessToken',data.accessToken);
          sessionStorage.setItem('username',data.username);
          sessionStorage.setItem('role',data.role);
          sessionStorage.setItem('userId',data.userId);
          if(ALLOWED_ROLES.includes(data.role)){
            redirectByRole(data.role);
          }else{
            showLoginError('Bạn không có quyền truy cập ứng dụng này. Vui lòng kiểm tra lại.');
          }
      }else{
        if(res.status >= 500 || res.status === 0){
          showLoginError('Lỗi kết nối máy chủ. Vui lòng thử lại sau.');
        }else{
          let message = 'Tên đăng nhập hoặc mật khẩu không đúng';
          try {
            const body = await res.json();
            if (body && typeof body.error === 'string' && body.error.trim()) {
              message = body.error.trim();
            }
          } catch (parseErr) {
            console.warn('Unable to read login error payload', parseErr);
          }
          showLoginError(message);
        }
      }
      }catch(err){
        showLoginError('Lỗi kết nối: '+err.message);
      }
    });
  }
});

function normalizeRole(role){
  if(!role){return ''; }
  return role.startsWith(ROLE_PREFIX) ? role.slice(ROLE_PREFIX.length) : role;
}
