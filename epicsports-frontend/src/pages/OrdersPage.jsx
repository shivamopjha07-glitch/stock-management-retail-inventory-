import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Package, Clock, CheckCircle, Truck, XCircle } from 'lucide-react';
import { orderApi } from '../api/client';
import useAuthStore from '../store/authStore';
import { useNavigate } from 'react-router-dom';

const STATUS_CONFIG = {
  PROCESSING: { icon: <Clock size={16} />, color: '#f59e0b', label: 'Processing' },
  SHIPPED: { icon: <Truck size={16} />, color: '#3b82f6', label: 'Shipped' },
  DELIVERED: { icon: <CheckCircle size={16} />, color: '#10b981', label: 'Delivered' },
  CANCELLED: { icon: <XCircle size={16} />, color: '#e94560', label: 'Cancelled' },
};

const OrdersPage = () => {
  const { isAuthenticated, user } = useAuthStore();
  const navigate = useNavigate();

  if (!isAuthenticated) {
    navigate('/login');
    return null;
  }

  const { data, isLoading, isError } = useQuery({
    queryKey: ['my-orders'],
    queryFn: () => orderApi.getMyOrders(),
    staleTime: 0,
  });

  const orders = data?.data?.data || [];

  return (
    <div className="orders-page">
      <div className="container container-md">
        <div className="page-header">
          <h1>My Orders</h1>
          <p>Track and manage your orders</p>
        </div>

        {isLoading ? (
          <div className="orders-skeleton">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="skeleton-order-card">
                <div className="skeleton skeleton-title" />
                <div className="skeleton skeleton-text" />
                <div className="skeleton skeleton-text short" />
              </div>
            ))}
          </div>
        ) : isError ? (
          <div className="error-state">
            <p>Failed to load orders. Please try again.</p>
          </div>
        ) : orders.length === 0 ? (
          <div className="empty-state">
            <Package size={60} />
            <h3>No orders yet</h3>
            <p>Start shopping to see your orders here</p>
            <button className="btn-primary" onClick={() => navigate('/products')} id="shop-now-btn">
              Shop Now
            </button>
          </div>
        ) : (
          <div className="orders-list">
            {orders.map((order) => {
              const status = STATUS_CONFIG[order.orderStatus] || STATUS_CONFIG.PROCESSING;
              return (
                <div key={order.id} className="order-card" id={`order-${order.orderNumber}`}>
                  <div className="order-card-header">
                    <div>
                      <p className="order-number">#{order.orderNumber}</p>
                      <p className="order-date">
                        {new Date(order.createdAt).toLocaleDateString('en-US', {
                          year: 'numeric', month: 'short', day: 'numeric'
                        })}
                      </p>
                    </div>
                    <div className="order-status-badge" style={{ '--status-color': status.color }}>
                      {status.icon}
                      <span>{status.label}</span>
                    </div>
                  </div>

                  <div className="order-items-preview">
                    {order.items?.slice(0, 3).map((item, i) => (
                      <div key={i} className="order-item-row">
                        <span>{item.product?.name || `Item ${i + 1}`}</span>
                        <span>× {item.quantity}</span>
                        <span>${(item.price * item.quantity).toFixed(2)}</span>
                      </div>
                    ))}
                    {order.items?.length > 3 && (
                      <p className="more-items">+{order.items.length - 3} more item(s)</p>
                    )}
                  </div>

                  <div className="order-card-footer">
                    <div className="order-payment-status" style={{
                      color: order.paymentStatus === 'PAID' ? '#10b981' : '#f59e0b'
                    }}>
                      {order.paymentStatus === 'PAID' ? <CheckCircle size={14} /> : <Clock size={14} />}
                      {order.paymentStatus}
                    </div>
                    <div className="order-total">
                      <strong>${order.totalAmount?.toFixed(2)}</strong>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default OrdersPage;
