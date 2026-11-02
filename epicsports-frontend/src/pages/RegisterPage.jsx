import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Eye, EyeOff, Zap, ArrowRight, Check } from 'lucide-react';
import useAuthStore from '../store/authStore';
import toast from 'react-hot-toast';

const RegisterPage = () => {
  const [form, setForm] = useState({
    username: '',
    email: '',
    fullName: '',
    password: '',
    confirmPassword: '',
  });
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const { register } = useAuthStore();
  const navigate = useNavigate();

  const handleChange = (e) => setForm({ ...form, [e.target.name]: e.target.value });

  const passwordStrength = () => {
    const p = form.password;
    if (!p) return 0;
    let score = 0;
    if (p.length >= 8) score++;
    if (/[A-Z]/.test(p)) score++;
    if (/[0-9]/.test(p)) score++;
    if (/[^A-Za-z0-9]/.test(p)) score++;
    return score;
  };

  const strength = passwordStrength();
  const strengthLabels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
  const strengthColors = ['', '#e94560', '#f59e0b', '#3b82f6', '#10b981'];

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.username || !form.email || !form.fullName || !form.password) {
      toast.error('Please fill in all fields');
      return;
    }
    if (form.password !== form.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }
    if (form.password.length < 6) {
      toast.error('Password must be at least 6 characters');
      return;
    }
    setLoading(true);
    try {
      await register({
        username: form.username,
        email: form.email,
        fullName: form.fullName,
        password: form.password,
      });
      toast.success('Account created! Welcome to EpicSports! 🎉');
      navigate('/');
    } catch (err) {
      toast.error(err.response?.data?.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-page">
      <div className="auth-bg">
        <div className="auth-blob blob1" />
        <div className="auth-blob blob2" />
      </div>

      <div className="auth-card auth-card-wide">
        <div className="auth-logo">
          <Zap size={32} className="logo-icon" />
          <span>Epic<strong>Sports</strong></span>
        </div>

        <div className="auth-header">
          <h1>Create Account</h1>
          <p>Join thousands of sports enthusiasts</p>
        </div>

        <form onSubmit={handleSubmit} className="auth-form" id="register-form">
          <div className="form-row">
            <div className="form-group">
              <label htmlFor="reg-fullname">Full Name</label>
              <input
                id="reg-fullname"
                type="text"
                name="fullName"
                value={form.fullName}
                onChange={handleChange}
                placeholder="John Doe"
                className="form-input"
              />
            </div>
            <div className="form-group">
              <label htmlFor="reg-username">Username</label>
              <input
                id="reg-username"
                type="text"
                name="username"
                value={form.username}
                onChange={handleChange}
                placeholder="johndoe"
                className="form-input"
                autoComplete="username"
              />
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="reg-email">Email</label>
            <input
              id="reg-email"
              type="email"
              name="email"
              value={form.email}
              onChange={handleChange}
              placeholder="john@example.com"
              className="form-input"
              autoComplete="email"
            />
          </div>

          <div className="form-group">
            <label htmlFor="reg-password">Password</label>
            <div className="password-wrap">
              <input
                id="reg-password"
                type={showPassword ? 'text' : 'password'}
                name="password"
                value={form.password}
                onChange={handleChange}
                placeholder="Create a strong password"
                className="form-input"
                autoComplete="new-password"
              />
              <button type="button" className="password-toggle" onClick={() => setShowPassword(!showPassword)}>
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
            {form.password && (
              <div className="password-strength">
                <div className="strength-bars">
                  {[1, 2, 3, 4].map((i) => (
                    <div
                      key={i}
                      className="strength-bar"
                      style={{ backgroundColor: i <= strength ? strengthColors[strength] : 'rgba(255,255,255,0.1)' }}
                    />
                  ))}
                </div>
                <span style={{ color: strengthColors[strength] }}>{strengthLabels[strength]}</span>
              </div>
            )}
          </div>

          <div className="form-group">
            <label htmlFor="reg-confirm-password">Confirm Password</label>
            <div className="password-wrap">
              <input
                id="reg-confirm-password"
                type={showPassword ? 'text' : 'password'}
                name="confirmPassword"
                value={form.confirmPassword}
                onChange={handleChange}
                placeholder="Repeat your password"
                className="form-input"
                autoComplete="new-password"
              />
              {form.confirmPassword && form.password === form.confirmPassword && (
                <span className="password-match"><Check size={18} /></span>
              )}
            </div>
          </div>

          <button
            type="submit"
            className="btn-primary full-width submit-btn"
            disabled={loading}
            id="register-submit-btn"
          >
            {loading ? (
              <span className="btn-spinner" />
            ) : (
              <>Create Account <ArrowRight size={18} /></>
            )}
          </button>
        </form>

        <p className="auth-switch">
          Already have an account?{' '}
          <Link to="/login" id="go-to-login">Sign In</Link>
        </p>
      </div>
    </div>
  );
};

export default RegisterPage;
