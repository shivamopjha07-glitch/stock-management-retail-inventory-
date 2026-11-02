import React, { useEffect } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from 'react-hot-toast';
import Navbar from './components/Navbar';
import CartDrawer from './components/CartDrawer';
import ProtectedRoute from './components/ProtectedRoute';
import HomePage from './pages/HomePage';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ProductsPage from './pages/ProductsPage';
import CheckoutPage from './pages/CheckoutPage';
import OrdersPage from './pages/OrdersPage';
import ProfilePage from './pages/ProfilePage';
import useAuthStore from './store/authStore';
import './App.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

const AppContent = () => {
  const { initAuth } = useAuthStore();

  useEffect(() => {
    initAuth();
  }, []);

  return (
    <>
      <Navbar />
      <CartDrawer />
      <main className="main-content">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/products" element={<ProductsPage />} />
          <Route
            path="/checkout"
            element={
              <ProtectedRoute>
                <CheckoutPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/orders"
            element={
              <ProtectedRoute>
                <OrdersPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/profile"
            element={
              <ProtectedRoute>
                <ProfilePage />
              </ProtectedRoute>
            }
          />
          <Route
            path="*"
            element={
              <div className="not-found">
                <h1>404</h1>
                <p>Page not found</p>
                <a href="/" className="btn-primary">Go Home</a>
              </div>
            }
          />
        </Routes>
      </main>
      <footer className="footer">
        <div className="container">
          <div className="footer-grid">
            <div className="footer-brand">
              <div className="footer-logo">⚡ EpicSports</div>
              <p>Premium sports gear for champions. Performance meets style.</p>
            </div>
            <div className="footer-links">
              <h4>Shop</h4>
              <a href="/products">All Products</a>
              <a href="/products?category=Footwear">Footwear</a>
              <a href="/products?category=Apparel">Apparel</a>
              <a href="/products?category=Equipment">Equipment</a>
            </div>
            <div className="footer-links">
              <h4>Account</h4>
              <a href="/login">Login</a>
              <a href="/register">Register</a>
              <a href="/orders">My Orders</a>
              <a href="/profile">Profile</a>
            </div>
            <div className="footer-links">
              <h4>Tech Stack</h4>
              <span>React + Vite</span>
              <span>Spring Boot 4</span>
              <span>JWT Auth</span>
              <span>H2 Database</span>
            </div>
          </div>
          <div className="footer-bottom">
            <p>© 2025 EpicSports. Built with ⚡ React + Java Spring Boot.</p>
          </div>
        </div>
      </footer>
    </>
  );
};

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <AppContent />
        <Toaster position="top-right" />
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;
