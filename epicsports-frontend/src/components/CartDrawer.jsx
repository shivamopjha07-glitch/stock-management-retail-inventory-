import React from 'react';
import { X, Plus, Minus, Trash2, ShoppingBag } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import useCartStore from '../store/cartStore';

const CartDrawer = () => {
  const { items, isOpen, closeCart, removeItem, updateQuantity, clearCart } = useCartStore();
  const navigate = useNavigate();

  const totalPrice = items.reduce((sum, i) => sum + i.price * i.quantity, 0);

  const handleCheckout = () => {
    closeCart();
    navigate('/checkout');
  };

  if (!isOpen) return null;

  return (
    <>
      <div className="cart-overlay" onClick={closeCart} />
      <div className="cart-drawer">
        <div className="cart-header">
          <div className="cart-title">
            <ShoppingBag size={20} />
            <h2>Your Cart</h2>
            <span className="cart-count">{items.length} item{items.length !== 1 ? 's' : ''}</span>
          </div>
          <button className="icon-btn" onClick={closeCart} id="close-cart-btn">
            <X size={22} />
          </button>
        </div>

        {items.length === 0 ? (
          <div className="cart-empty">
            <ShoppingBag size={60} className="cart-empty-icon" />
            <p>Your cart is empty</p>
            <button className="btn-primary" onClick={() => { closeCart(); navigate('/products'); }} id="cart-shop-btn">
              Start Shopping
            </button>
          </div>
        ) : (
          <>
            <div className="cart-items">
              {items.map((item) => (
                <div key={item.id} className="cart-item">
                  <div className="cart-item-img">
                    <img
                      src={item.imageUrl || `https://placehold.co/80x80/1a1a2e/e94560?text=${encodeURIComponent(item.name[0])}`}
                      alt={item.name}
                    />
                  </div>
                  <div className="cart-item-info">
                    <h4>{item.name}</h4>
                    <p className="cart-item-category">{item.category}</p>
                    <p className="cart-item-price">${(item.price * item.quantity).toFixed(2)}</p>
                  </div>
                  <div className="cart-item-controls">
                    <div className="qty-control">
                      <button
                        className="qty-btn"
                        onClick={() => updateQuantity(item.id, item.quantity - 1)}
                        id={`qty-minus-${item.id}`}
                      >
                        <Minus size={14} />
                      </button>
                      <span>{item.quantity}</span>
                      <button
                        className="qty-btn"
                        onClick={() => updateQuantity(item.id, item.quantity + 1)}
                        id={`qty-plus-${item.id}`}
                      >
                        <Plus size={14} />
                      </button>
                    </div>
                    <button
                      className="remove-btn"
                      onClick={() => removeItem(item.id)}
                      id={`remove-item-${item.id}`}
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              ))}
            </div>

            <div className="cart-footer">
              <div className="cart-total">
                <span>Total</span>
                <strong>${totalPrice.toFixed(2)}</strong>
              </div>
              <button className="btn-primary full-width" onClick={handleCheckout} id="checkout-btn">
                Proceed to Checkout
              </button>
              <button className="btn-ghost full-width clear-btn" onClick={clearCart} id="clear-cart-btn">
                Clear Cart
              </button>
            </div>
          </>
        )}
      </div>
    </>
  );
};

export default CartDrawer;
