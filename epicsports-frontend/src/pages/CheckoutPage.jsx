import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CreditCard, MapPin, Package, Check, ArrowLeft } from 'lucide-react';
import { useMutation } from '@tanstack/react-query';
import { orderApi } from '../api/client';
import useCartStore from '../store/cartStore';
import useAuthStore from '../store/authStore';
import toast from 'react-hot-toast';

const STEPS = ['Cart Review', 'Shipping', 'Payment', 'Confirm'];

const CheckoutPage = () => {
  const { items, clearCart } = useCartStore();
  const { isAuthenticated } = useAuthStore();
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [shipping, setShipping] = useState({
    fullName: '',
    address: '',
    city: '',
    state: '',
    zip: '',
    country: 'US',
  });
  const [paymentMethod, setPaymentMethod] = useState('CREDIT_CARD');
  const [orderPlaced, setOrderPlaced] = useState(null);

  const totalPrice = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const shipping_cost = totalPrice >= 75 ? 0 : 9.99;
  const tax = totalPrice * 0.08;
  const grandTotal = totalPrice + shipping_cost + tax;

  const createOrderMutation = useMutation({
    mutationFn: (orderData) => orderApi.create(orderData),
    onSuccess: (res) => {
      const order = res.data.data;
      setOrderPlaced(order);
      clearCart();
      setStep(5);
      toast.success('Order placed successfully! 🎉');
    },
    onError: (err) => {
      toast.error(err.response?.data?.message || 'Failed to place order');
    },
  });

  if (!isAuthenticated) {
    navigate('/login', { state: { from: { pathname: '/checkout' } } });
    return null;
  }

  if (items.length === 0 && step !== 5) {
    navigate('/products');
    return null;
  }

  const handleShippingChange = (e) =>
    setShipping({ ...shipping, [e.target.name]: e.target.value });

  const handlePlaceOrder = () => {
    const shippingAddress = `${shipping.fullName}, ${shipping.address}, ${shipping.city}, ${shipping.state} ${shipping.zip}, ${shipping.country}`;
    createOrderMutation.mutate({
      items: items.map((i) => ({
        productId: i.id,
        quantity: i.quantity,
      })),
      shippingAddress,
      paymentMethod,
    });
  };

  // Order Success Screen
  if (step === 5 && orderPlaced) {
    return (
      <div className="checkout-page">
        <div className="container container-sm">
          <div className="order-success">
            <div className="success-icon">
              <Check size={48} />
            </div>
            <h1>Order Confirmed! 🎉</h1>
            <p>Your order has been placed successfully.</p>
            <div className="order-number-box">
              <span>Order Number</span>
              <strong>{orderPlaced.orderNumber}</strong>
            </div>
            <div className="success-actions">
              <button className="btn-primary" onClick={() => navigate('/orders')} id="view-orders-btn">
                View My Orders
              </button>
              <button className="btn-ghost" onClick={() => navigate('/products')} id="continue-shopping-btn">
                Continue Shopping
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="checkout-page">
      <div className="container">
        {/* Stepper */}
        <div className="checkout-stepper">
          {STEPS.map((label, i) => (
            <React.Fragment key={label}>
              <div className={`step ${step > i ? 'completed' : step === i + 1 ? 'active' : ''}`}>
                <div className="step-circle">
                  {step > i + 1 ? <Check size={14} /> : i + 1}
                </div>
                <span className="step-label">{label}</span>
              </div>
              {i < STEPS.length - 1 && <div className={`step-line ${step > i + 1 ? 'filled' : ''}`} />}
            </React.Fragment>
          ))}
        </div>

        <div className="checkout-layout">
          {/* Main Content */}
          <div className="checkout-main">
            {/* Step 1: Cart Review */}
            {step === 1 && (
              <div className="checkout-section">
                <h2><Package size={20} /> Review Your Cart</h2>
                {items.map((item) => (
                  <div key={item.id} className="checkout-item">
                    <div className="checkout-item-img">
                      <img
                        src={item.imageUrl || `https://placehold.co/60x60/1a1a2e/e94560?text=${item.name[0]}`}
                        alt={item.name}
                      />
                    </div>
                    <div className="checkout-item-info">
                      <h4>{item.name}</h4>
                      <p>Qty: {item.quantity}</p>
                    </div>
                    <strong>${(item.price * item.quantity).toFixed(2)}</strong>
                  </div>
                ))}
                <button className="btn-primary full-width" onClick={() => setStep(2)} id="next-to-shipping">
                  Continue to Shipping
                </button>
              </div>
            )}

            {/* Step 2: Shipping */}
            {step === 2 && (
              <div className="checkout-section">
                <h2><MapPin size={20} /> Shipping Address</h2>
                <form
                  id="shipping-form"
                  onSubmit={(e) => { e.preventDefault(); setStep(3); }}
                >
                  <div className="form-row">
                    <div className="form-group">
                      <label>Full Name</label>
                      <input type="text" name="fullName" value={shipping.fullName} onChange={handleShippingChange} className="form-input" required placeholder="John Doe" />
                    </div>
                    <div className="form-group">
                      <label>Country</label>
                      <select name="country" value={shipping.country} onChange={handleShippingChange} className="form-input">
                        <option value="US">United States</option>
                        <option value="IN">India</option>
                        <option value="UK">United Kingdom</option>
                        <option value="CA">Canada</option>
                      </select>
                    </div>
                  </div>
                  <div className="form-group">
                    <label>Street Address</label>
                    <input type="text" name="address" value={shipping.address} onChange={handleShippingChange} className="form-input" required placeholder="123 Main St" />
                  </div>
                  <div className="form-row">
                    <div className="form-group">
                      <label>City</label>
                      <input type="text" name="city" value={shipping.city} onChange={handleShippingChange} className="form-input" required placeholder="New York" />
                    </div>
                    <div className="form-group">
                      <label>State</label>
                      <input type="text" name="state" value={shipping.state} onChange={handleShippingChange} className="form-input" required placeholder="NY" />
                    </div>
                    <div className="form-group">
                      <label>ZIP Code</label>
                      <input type="text" name="zip" value={shipping.zip} onChange={handleShippingChange} className="form-input" required placeholder="10001" />
                    </div>
                  </div>
                  <div className="form-actions">
                    <button type="button" className="btn-ghost" onClick={() => setStep(1)} id="back-to-cart">
                      <ArrowLeft size={16} /> Back
                    </button>
                    <button type="submit" className="btn-primary" id="next-to-payment">
                      Continue to Payment
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* Step 3: Payment */}
            {step === 3 && (
              <div className="checkout-section">
                <h2><CreditCard size={20} /> Payment Method</h2>
                <div className="payment-options">
                  {[
                    { value: 'CREDIT_CARD', label: 'Credit Card', icon: '💳' },
                    { value: 'DEBIT_CARD', label: 'Debit Card', icon: '🏧' },
                    { value: 'UPI', label: 'UPI / Net Banking', icon: '📱' },
                    { value: 'COD', label: 'Cash on Delivery', icon: '💵' },
                  ].map((opt) => (
                    <label key={opt.value} className={`payment-option ${paymentMethod === opt.value ? 'selected' : ''}`}>
                      <input
                        type="radio"
                        name="paymentMethod"
                        value={opt.value}
                        checked={paymentMethod === opt.value}
                        onChange={() => setPaymentMethod(opt.value)}
                      />
                      <span className="payment-emoji">{opt.icon}</span>
                      <span>{opt.label}</span>
                      {paymentMethod === opt.value && <Check size={16} className="payment-check" />}
                    </label>
                  ))}
                </div>
                {(paymentMethod === 'CREDIT_CARD' || paymentMethod === 'DEBIT_CARD') && (
                  <div className="card-demo-note">
                    <p>🔒 This is a demo. No real payment is processed.</p>
                    <div className="form-row">
                      <div className="form-group">
                        <label>Card Number</label>
                        <input type="text" className="form-input" placeholder="4242 4242 4242 4242" readOnly />
                      </div>
                      <div className="form-group">
                        <label>Expiry</label>
                        <input type="text" className="form-input" placeholder="12/28" readOnly />
                      </div>
                      <div className="form-group">
                        <label>CVV</label>
                        <input type="text" className="form-input" placeholder="123" readOnly />
                      </div>
                    </div>
                  </div>
                )}
                <div className="form-actions">
                  <button className="btn-ghost" onClick={() => setStep(2)} id="back-to-shipping"><ArrowLeft size={16} /> Back</button>
                  <button className="btn-primary" onClick={() => setStep(4)} id="next-to-confirm">Review Order</button>
                </div>
              </div>
            )}

            {/* Step 4: Confirm */}
            {step === 4 && (
              <div className="checkout-section">
                <h2>Confirm Order</h2>
                <div className="confirm-details">
                  <div className="confirm-row">
                    <span>Shipping to</span>
                    <strong>{shipping.address}, {shipping.city}</strong>
                  </div>
                  <div className="confirm-row">
                    <span>Payment</span>
                    <strong>{paymentMethod.replace('_', ' ')}</strong>
                  </div>
                  <div className="confirm-row">
                    <span>Items</span>
                    <strong>{items.length} item(s)</strong>
                  </div>
                </div>
                <div className="form-actions">
                  <button className="btn-ghost" onClick={() => setStep(3)} id="back-to-payment"><ArrowLeft size={16} /> Back</button>
                  <button
                    className="btn-primary"
                    onClick={handlePlaceOrder}
                    disabled={createOrderMutation.isPending}
                    id="place-order-btn"
                  >
                    {createOrderMutation.isPending ? <span className="btn-spinner" /> : 'Place Order 🎉'}
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Order Summary Sidebar */}
          <div className="checkout-sidebar">
            <h3>Order Summary</h3>
            <div className="summary-items">
              {items.map((item) => (
                <div key={item.id} className="summary-item">
                  <span>{item.name} × {item.quantity}</span>
                  <span>${(item.price * item.quantity).toFixed(2)}</span>
                </div>
              ))}
            </div>
            <div className="summary-divider" />
            <div className="summary-row">
              <span>Subtotal</span>
              <span>${totalPrice.toFixed(2)}</span>
            </div>
            <div className="summary-row">
              <span>Shipping</span>
              <span>{shipping_cost === 0 ? <span className="free-badge">FREE</span> : `$${shipping_cost.toFixed(2)}`}</span>
            </div>
            <div className="summary-row">
              <span>Tax (8%)</span>
              <span>${tax.toFixed(2)}</span>
            </div>
            <div className="summary-divider" />
            <div className="summary-row summary-total">
              <strong>Total</strong>
              <strong>${grandTotal.toFixed(2)}</strong>
            </div>
            {totalPrice < 75 && (
              <p className="shipping-note">Add ${(75 - totalPrice).toFixed(2)} more for free shipping!</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CheckoutPage;
