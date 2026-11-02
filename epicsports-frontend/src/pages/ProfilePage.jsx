import React from 'react';
import { User, Mail, Shield, ShoppingBag, LogOut } from 'lucide-react';
import useAuthStore from '../store/authStore';
import { useNavigate, Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { orderApi } from '../api/client';

const ProfilePage = () => {
  const { user, isAuthenticated, logout } = useAuthStore();
  const navigate = useNavigate();

  if (!isAuthenticated) {
    navigate('/login');
    return null;
  }

  const { data } = useQuery({
    queryKey: ['my-orders'],
    queryFn: () => orderApi.getMyOrders(),
    staleTime: 0,
  });

  const orders = data?.data?.data || [];
  const totalSpent = orders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const roleBadge = user?.role === 'ROLE_ADMIN' ? '👑 Admin' : '🏃 Athlete';

  return (
    <div className="profile-page">
      <div className="container container-md">
        <div className="profile-card">
          {/* Avatar */}
          <div className="profile-avatar">
            <div className="avatar-circle">
              {user?.fullName?.[0] || user?.username?.[0] || 'U'}
            </div>
            <div className="profile-info">
              <h1>{user?.fullName}</h1>
              <p className="profile-username">@{user?.username}</p>
              <span className="role-badge">{roleBadge}</span>
            </div>
          </div>

          {/* Stats */}
          <div className="profile-stats">
            <div className="profile-stat">
              <strong>{orders.length}</strong>
              <span>Orders</span>
            </div>
            <div className="profile-stat">
              <strong>${totalSpent.toFixed(0)}</strong>
              <span>Total Spent</span>
            </div>
            <div className="profile-stat">
              <strong>
                {orders.filter(o => o.orderStatus === 'DELIVERED').length}
              </strong>
              <span>Delivered</span>
            </div>
          </div>

          {/* Info */}
          <div className="profile-details">
            <div className="profile-detail-row">
              <User size={18} />
              <div>
                <label>Full Name</label>
                <p>{user?.fullName}</p>
              </div>
            </div>
            <div className="profile-detail-row">
              <Mail size={18} />
              <div>
                <label>Email</label>
                <p>{user?.email}</p>
              </div>
            </div>
            <div className="profile-detail-row">
              <Shield size={18} />
              <div>
                <label>Role</label>
                <p>{user?.role?.replace('ROLE_', '') || 'Customer'}</p>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="profile-actions">
            <Link to="/orders" className="btn-primary" id="view-orders-link">
              <ShoppingBag size={18} /> View My Orders
            </Link>
            <button className="btn-ghost danger-btn" onClick={handleLogout} id="profile-logout-btn">
              <LogOut size={18} /> Logout
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProfilePage;
