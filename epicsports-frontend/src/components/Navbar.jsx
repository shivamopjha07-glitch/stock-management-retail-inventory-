import React, { useState } from 'react';
import { Link, NavLink, useNavigate } from 'react-router-dom';
import { ShoppingCart, User, LogOut, Menu, X, Zap } from 'lucide-react';
import useAuthStore from '../store/authStore';
import useCartStore from '../store/cartStore';

const Navbar = () => {
  const { isAuthenticated, user, logout } = useAuthStore();
  const { items, toggleCart } = useCartStore();
  const navigate = useNavigate();
  const [mobileOpen, setMobileOpen] = useState(false);

  const totalItems = items.reduce((sum, i) => sum + i.quantity, 0);

  const handleLogout = () => {
    logout();
    navigate('/');
    setMobileOpen(false);
  };

  const navLinks = [
    { to: '/', label: 'Home' },
    { to: '/products', label: 'Shop' },
    { to: '/products?category=Footwear', label: 'Footwear' },
    { to: '/products?category=Apparel', label: 'Apparel' },
    { to: '/products?category=Equipment', label: 'Equipment' },
  ];

  return (
    <nav className="navbar">
      <div className="navbar-container">
        {/* Logo */}
        <Link to="/" className="navbar-logo">
          <Zap size={24} className="logo-icon" />
          <span>Epic<strong>Sports</strong></span>
        </Link>

        {/* Desktop Nav Links */}
        <div className="navbar-links desktop-only">
          {navLinks.map((link) => (
            <NavLink key={link.to} to={link.to} className="nav-link">
              {link.label}
            </NavLink>
          ))}
        </div>

        {/* Right Actions */}
        <div className="navbar-actions">
          {/* Cart Button */}
          <button className="icon-btn cart-btn" onClick={toggleCart} aria-label="Open cart" id="cart-toggle-btn">
            <ShoppingCart size={22} />
            {totalItems > 0 && (
              <span className="cart-badge">{totalItems}</span>
            )}
          </button>

          {/* Auth Actions */}
          {isAuthenticated ? (
            <div className="user-menu desktop-only">
              <Link to="/profile" className="user-chip" id="user-profile-link">
                <User size={16} />
                <span>{user?.fullName?.split(' ')[0] || user?.username}</span>
              </Link>
              <button className="icon-btn logout-btn" onClick={handleLogout} id="logout-btn" title="Logout">
                <LogOut size={20} />
              </button>
            </div>
          ) : (
            <div className="auth-btns desktop-only">
              <Link to="/login" className="btn-ghost" id="nav-login-btn">Login</Link>
              <Link to="/register" className="btn-primary" id="nav-register-btn">Sign Up</Link>
            </div>
          )}

          {/* Mobile Hamburger */}
          <button
            className="icon-btn mobile-only"
            onClick={() => setMobileOpen(!mobileOpen)}
            aria-label="Toggle menu"
            id="mobile-menu-btn"
          >
            {mobileOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {mobileOpen && (
        <div className="mobile-menu">
          {navLinks.map((link) => (
            <NavLink key={link.to} to={link.to} className="mobile-nav-link" onClick={() => setMobileOpen(false)}>
              {link.label}
            </NavLink>
          ))}
          <div className="mobile-divider" />
          {isAuthenticated ? (
            <>
              <Link to="/profile" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>My Profile</Link>
              <Link to="/orders" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>My Orders</Link>
              <button className="mobile-nav-link logout-mobile" onClick={handleLogout}>Logout</button>
            </>
          ) : (
            <>
              <Link to="/login" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>Login</Link>
              <Link to="/register" className="mobile-nav-link" onClick={() => setMobileOpen(false)}>Sign Up</Link>
            </>
          )}
        </div>
      )}
    </nav>
  );
};

export default Navbar;
