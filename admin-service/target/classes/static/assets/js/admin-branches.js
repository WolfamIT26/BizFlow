const ADMIN_API_BASE = "/admin";
const ROLE_PREFIX = 'ROLE_';

const endpoints = {
    summary: `${ADMIN_API_BASE}/api/admin/branches/summary`,
    growth: (branchId) => `${ADMIN_API_BASE}/api/admin/branches/${branchId}/growth?months=6`
};

let branchChart = null;

window.addEventListener("load", () => {
    enforceAuth();
    renderHeader();
    loadBranchSummary();
});

function enforceAuth() {
    const token = getToken() || localStorage.getItem("accessToken");
    const roleRaw = sessionStorage.getItem("role") || localStorage.getItem("role");
    const role = normalizeRole(roleRaw);
    if (!token) {
        window.location.href = "/pages/login.html";
        return;
    }
    sessionStorage.setItem("accessToken", token);
    if (role) {
        sessionStorage.setItem("role", role);
    }
    if (role !== "ADMIN") {
        if (role === "OWNER") {
            window.location.href = "/pages/owner-dashboard.html";
        } else {
            window.location.href = "/pages/employee-dashboard.html";
        }
    }
}

function renderHeader() {
    const username = sessionStorage.getItem("username") || "Admin";
    const avatar = document.getElementById("userAvatar");
    const greeting = document.getElementById("userGreeting");
    const timeEl = document.getElementById("sidebarTime");
    if (avatar) avatar.textContent = initials(username);
    if (greeting) greeting.textContent = username;
    if (timeEl) timeEl.textContent = new Date().toLocaleString("vi-VN", { hour12: false });
}

async function loadBranchSummary() {
    const tbody = document.getElementById("branchTableBody");
    const select = document.getElementById("branchSelect");
    try {
        const response = await fetch(endpoints.summary, {
            headers: { "Authorization": `Bearer ${getToken()}` }
        });
        if (!response.ok) {
            throw new Error("Không tải được dữ liệu chi nhánh");
        }
        const data = await response.json();
        updateSummaryCards(data);
        renderBranchTable(data.branches || []);
        populateBranchSelect(select, data.branches || []);
        const firstBranch = (data.branches || [])[0];
        if (firstBranch && firstBranch.id) {
            select.value = String(firstBranch.id);
            await loadBranchGrowth(firstBranch.id, firstBranch.name);
        }
    } catch (error) {
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Không thể tải dữ liệu chi nhánh.</td></tr>';
        }
    }
}

function updateSummaryCards(data) {
    setText("totalBranches", data.totalBranches ?? "--");
    setText("activeBranches", data.activeBranches ?? "--");
    setText("totalRevenue", formatCurrency(data.totalRevenue));
}

function renderBranchTable(branches) {
    const tbody = document.getElementById("branchTableBody");
    if (!tbody) return;
    if (!branches.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="empty-box">Chưa có dữ liệu chi nhánh.</td></tr>';
        return;
    }
    tbody.innerHTML = branches.map(branch => {
        const status = branch.active ? "Đang hoạt động" : "Tạm ngưng";
        return `
            <tr>
                <td>${escapeHtml(branch.name || "-")}</td>
                <td>${escapeHtml(branch.ownerName || "-")}</td>
                <td>${status}</td>
                <td>${formatCurrency(branch.totalRevenue)}</td>
                <td>${branch.orderCount ?? 0}</td>
            </tr>
        `;
    }).join("");
}

function populateBranchSelect(select, branches) {
    if (!select) return;
    select.innerHTML = "";
    branches.forEach(branch => {
        const option = document.createElement("option");
        option.value = branch.id;
        option.textContent = branch.name || `Chi nhánh ${branch.id}`;
        select.appendChild(option);
    });
    select.addEventListener("change", async () => {
        const branchId = select.value;
        const branch = branches.find(b => String(b.id) === String(branchId));
        await loadBranchGrowth(branchId, branch ? branch.name : null);
    });
}

async function loadBranchGrowth(branchId, branchName) {
    if (!branchId) return;
    const subtitle = document.getElementById("chartSubtitle");
    if (subtitle) {
        subtitle.textContent = `Tăng trưởng 6 tháng gần nhất - ${branchName || "Chi nhánh"}`;
    }
    try {
        const response = await fetch(endpoints.growth(branchId), {
            headers: { "Authorization": `Bearer ${getToken()}` }
        });
        if (!response.ok) {
            throw new Error("Không tải được dữ liệu tăng trưởng");
        }
        const data = await response.json();
        renderChart(data.points || []);
    } catch (error) {
        renderChart([]);
    }
}

function renderChart(points) {
    const ctx = document.getElementById("branchChart");
    if (!ctx) return;
    const labels = points.map(p => p.label);
    const values = points.map(p => Number(p.totalRevenue || 0));
    if (branchChart) {
        branchChart.data.labels = labels;
        branchChart.data.datasets[0].data = values;
        branchChart.update();
        return;
    }
    branchChart = new Chart(ctx, {
        type: "line",
        data: {
            labels,
            datasets: [{
                label: "Doanh thu",
                data: values,
                borderColor: "#0f766e",
                backgroundColor: "rgba(15,118,110,0.15)",
                tension: 0.3,
                fill: true
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    ticks: {
                        callback: value => formatCurrency(value)
                    }
                }
            }
        }
    });
}

function logout() {
    if (confirm("Bạn có chắc muốn đăng xuất?")) {
        sessionStorage.clear();
        window.location.href = "/pages/login.html";
    }
}

function initials(name) {
    return name.split(" ").map(part => part[0]).join("").slice(0, 2).toUpperCase() || "AD";
}

function setText(id, value) {
    const el = document.getElementById(id);
    if (el) el.textContent = value;
}

function formatCurrency(value) {
    if (value === null || value === undefined) return "--";
    const numberValue = typeof value === "number" ? value : Number(value);
    if (Number.isNaN(numberValue)) return "--";
    return new Intl.NumberFormat("vi-VN").format(numberValue) + " đ";
}

function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, match => ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#39;"
    }[match]));
}

function normalizeRole(role){
    if(!role){return ''; }
    return role.startsWith(ROLE_PREFIX) ? role.slice(ROLE_PREFIX.length) : role;
}

function getToken() {
    return sessionStorage.getItem('accessToken') || localStorage.getItem('accessToken') || '';
}
