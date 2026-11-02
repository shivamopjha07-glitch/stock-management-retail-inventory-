import React from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ArrowRight, Zap, Shield, Truck, Star, ChevronRight } from 'lucide-react';
import { productApi } from '../api/client';
import ProductCard from '../components/ProductCard';

const HERO_CATEGORIES = [
  { name: 'Soccer', emoji: '⚽', color: '#10b981' },
  { name: 'Basketball', emoji: '🏀', color: '#f59e0b' },
  { name: 'Running', emoji: '🏃', color: '#e94560' },
  { name: 'Baseball', emoji: '⚾', color: '#3b82f6' },
  { name: 'Fitness', emoji: '💪', color: '#8b5cf6' },
];

const FEATURES = [
  { icon: <Truck size={28} />, title: 'Free Shipping', desc: 'On all orders over $75' },
  { icon: <Shield size={28} />, title: 'Secure Payment', desc: 'JWT-secured transactions' },
  { icon: <Star size={28} />, title: 'Premium Quality', desc: 'Curated top-tier gear' },
  { icon: <Zap size={28} />, title: 'Fast Delivery', desc: '2–5 business days' },
];

const HomePage = () => {
  const { data: featuredData } = useQuery({
    queryKey: ['products', 'featured'],
    queryFn: () => productApi.getAll({ featured: true }),
    staleTime: 5 * 60 * 1000,
  });

  const featuredProducts = featuredData?.data?.data?.slice(0, 4) || [];

  return (
    <div className="home-page">
      {/* Hero Section */}
      <section className="hero">
        <div className="hero-bg">
          <div className="hero-orb orb1" />
          <div className="hero-orb orb2" />
          <div className="hero-orb orb3" />
          <div className="hero-grid" />
        </div>
        <div className="hero-content">
          <div className="hero-badge">
            <Zap size={14} />
            <span>New Season 2025 Collection</span>
          </div>
          <h1 className="hero-title">
            Gear Up For <br />
            <span className="gradient-text">Greatness</span>
          </h1>
          <p className="hero-subtitle">
            Premium sports equipment, apparel & footwear for champions. 
            Built for performance. Crafted for style.
          </p>
          <div className="hero-actions">
            <Link to="/products" className="btn-primary btn-lg" id="hero-shop-btn">
              Shop Now <ArrowRight size={20} />
            </Link>
            <Link to="/products?featured=true" className="btn-ghost btn-lg" id="hero-featured-btn">
              View Featured
            </Link>
          </div>
          <div className="hero-stats">
            <div className="stat">
              <strong>2,400+</strong>
              <span>Products</span>
            </div>
            <div className="stat-divider" />
            <div className="stat">
              <strong>50K+</strong>
              <span>Happy Athletes</span>
            </div>
            <div className="stat-divider" />
            <div className="stat">
              <strong>4.9★</strong>
              <span>Avg Rating</span>
            </div>
          </div>
        </div>
      </section>

      {/* Sports Categories */}
      <section className="section sports-section">
        <div className="container">
          <div className="section-header">
            <h2>Shop by Sport</h2>
            <Link to="/products" className="see-all-link">
              All Categories <ChevronRight size={16} />
            </Link>
          </div>
          <div className="sports-grid">
            {HERO_CATEGORIES.map((sport) => (
              <Link
                key={sport.name}
                to={`/products?sport=${sport.name}`}
                className="sport-chip"
                id={`sport-chip-${sport.name.toLowerCase()}`}
                style={{ '--sport-color': sport.color }}
              >
                <span className="sport-emoji">{sport.emoji}</span>
                <span>{sport.name}</span>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* Featured Products */}
      {featuredProducts.length > 0 && (
        <section className="section featured-section">
          <div className="container">
            <div className="section-header">
              <div>
                <div className="section-eyebrow">
                  <Zap size={14} /> Featured Picks
                </div>
                <h2>Top Performers</h2>
              </div>
              <Link to="/products?featured=true" className="see-all-link">
                View All <ChevronRight size={16} />
              </Link>
            </div>
            <div className="products-grid">
              {featuredProducts.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          </div>
        </section>
      )}

      {/* Features Banner */}
      <section className="features-section">
        <div className="container">
          <div className="features-grid">
            {FEATURES.map((f, i) => (
              <div key={i} className="feature-card">
                <div className="feature-icon">{f.icon}</div>
                <div>
                  <h4>{f.title}</h4>
                  <p>{f.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="cta-section">
        <div className="container">
          <div className="cta-card">
            <div className="cta-content">
              <h2>Ready to Level Up?</h2>
              <p>Join EpicSports today and get 10% off your first order.</p>
              <Link to="/register" className="btn-primary btn-lg" id="cta-register-btn">
                Get Started <ArrowRight size={20} />
              </Link>
            </div>
            <div className="cta-decoration">
              <div className="cta-orb" />
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default HomePage;
