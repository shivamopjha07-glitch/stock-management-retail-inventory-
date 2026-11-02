const { useState, useEffect } = React;

const API_BASE = window.location.origin;

function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('shop'); // 'shop', 'customizer', 'orders'
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [selectedSport, setSelectedSport] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Auth state
  const [token, setToken] = useState(localStorage.getItem('es_token') || '');
  const [user, setUser] = useState(null);
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [authMode, setAuthMode] = useState('login'); // 'login' or 'register'
  const [authForm, setAuthForm] = useState({ username: '', email: '', password: '', fullName: '' });
  const [authError, setAuthError] = useState('');

  // Cart & Checkout state
  const [cart, setCart] = useState(() => {
    try {
      return JSON.parse(localStorage.getItem('es_cart')) || [];
    } catch {
      return [];
    }
  });
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [isCheckoutOpen, setIsCheckoutOpen] = useState(false);
  const [checkoutForm, setCheckoutForm] = useState({
    shippingAddress: '124 Champion Way, Suite 400, Chicago, IL 60601',
    paymentMethod: 'CREDIT_CARD'
  });
  const [orderSuccess, setOrderSuccess] = useState(null);

  // Customizer state
  const [customName, setCustomName] = useState('PRAJAPATI');
  const [customNumber, setCustomNumber] = useState('10');
  const [customColor, setCustomColor] = useState('#0284c7');
  const [customQty, setCustomQty] = useState(15);
  const [customQuote, setCustomQuote] = useState(null);

  // Orders list
  const [myOrders, setMyOrders] = useState([]);

  // Product detail modal
  const [selectedProduct, setSelectedProduct] = useState(null);

  // Save cart
  useEffect(() => {
    localStorage.setItem('es_cart', JSON.stringify(cart));
  }, [cart]);

  // Load products
  const fetchProducts = async () => {
    setLoading(true);
    try {
      let url = `${API_BASE}/api/products`;
      const params = new URLSearchParams();
      if (selectedCategory !== 'All') params.append('category', selectedCategory);
      if (selectedSport !== 'All') params.append('sport', selectedSport);
      if (searchQuery.trim()) params.append('search', searchQuery.trim());
      
      const queryString = params.toString();
      if (queryString) url += `?${queryString}`;

      const res = await fetch(url);
      const data = await res.json();
      if (data.success) {
        setProducts(data.data);
      }
    } catch (err) {
      console.error('Failed to load products from Java backend:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, [selectedCategory, selectedSport]);

  // Check auth
  useEffect(() => {
    if (token) {
      fetch(`${API_BASE}/api/auth/me`, {
        headers: { 'Authorization': `Bearer ${token}` }
      })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          setUser(data.data);
        } else {
          logout();
        }
      })
      .catch(() => logout());
    }
  }, [token]);

  // Fetch orders
  const fetchOrders = async () => {
    if (!token) return;
    try {
      const res = await fetch(`${API_BASE}/api/orders/my-orders`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await res.json();
      if (data.success) {
        setMyOrders(data.data);
      }
    } catch (err) {
      console.error('Error fetching orders:', err);
    }
  };

  useEffect(() => {
    if (activeTab === 'orders') {
      fetchOrders();
    }
  }, [activeTab, token]);

  // Customizer Quote Calculation API call
  useEffect(() => {
    fetch(`${API_BASE}/api/customizer/calculate-quote`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ basePrice: 54.99, quantity: customQty })
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) setCustomQuote(data.data);
    })
    .catch(console.error);
  }, [customQty]);

  // Cart operations
  const addToCart = (product, customization = null) => {
    setCart(prev => {
      const existing = prev.find(item => item.product.id === product.id && item.customization === customization);
      if (existing) {
        return prev.map(item => item === existing ? { ...item, quantity: item.quantity + 1 } : item);
      }
      return [...prev, { product, quantity: 1, customization }];
    });
    setIsCartOpen(true);
  };

  const updateQuantity = (index, delta) => {
    setCart(prev => {
      const copy = [...prev];
      copy[index].quantity += delta;
      if (copy[index].quantity <= 0) {
        copy.splice(index, 1);
      }
      return copy;
    });
  };

  const cartSubtotal = cart.reduce((sum, item) => sum + (item.product.price * item.quantity), 0);
  const cartItemCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  // Authentication
  const handleAuthSubmit = async (e) => {
    e.preventDefault();
    setAuthError('');
    const endpoint = authMode === 'login' ? '/api/auth/login' : '/api/auth/register';

    try {
      const res = await fetch(`${API_BASE}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(authForm)
      });
      const data = await res.json();
      if (data.success) {
        localStorage.setItem('es_token', data.data.token);
        setToken(data.data.token);
        setUser({
          username: data.data.username,
          email: data.data.email,
          fullName: data.data.fullName,
          role: data.data.role
        });
        setIsAuthOpen(false);
      } else {
        setAuthError(data.message || 'Authentication failed');
      }
    } catch {
      setAuthError('Backend server connection error');
    }
  };

  const logout = () => {
    localStorage.removeItem('es_token');
    setToken('');
    setUser(null);
  };

  // Place Order
  const handleCheckout = async (e) => {
    e.preventDefault();
    if (!token) {
      setIsCheckoutOpen(false);
      setIsAuthOpen(true);
      return;
    }

    try {
      const payload = {
        shippingAddress: checkoutForm.shippingAddress,
        paymentMethod: checkoutForm.paymentMethod,
        items: cart.map(item => ({
          productId: item.product.id,
          quantity: item.quantity,
          customizationDetails: item.customization
        }))
      };

      const res = await fetch(`${API_BASE}/api/orders`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (data.success) {
        setOrderSuccess(data.data);
        setCart([]);
        setIsCheckoutOpen(false);
        fetchProducts(); // refresh stock counts
      } else {
        alert(data.message || 'Checkout failed');
      }
    } catch (err) {
      alert('Error placing order: ' + err.message);
    }
  };

  return (
    <div>
      {/* Top Navigation */}
      <nav className="navbar">
        <div className="nav-brand" onClick={() => setActiveTab('shop')}>
          <div className="brand-badge">ES</div>
          <div className="brand-title">Epic Sports</div>
        </div>

        <div className="nav-links">
          <button className={`nav-link ${activeTab === 'shop' ? 'active' : ''}`} onClick={() => setActiveTab('shop')}>
            Gear Store
          </button>
          <button className={`nav-link ${activeTab === 'customizer' ? 'active' : ''}`} onClick={() => setActiveTab('customizer')}>
            Team Uniform Studio
          </button>
          <button className={`nav-link ${activeTab === 'orders' ? 'active' : ''}`} onClick={() => {
            if (!token) setIsAuthOpen(true);
            else setActiveTab('orders');
          }}>
            My Orders
          </button>
          <a href="/h2-console" target="_blank" className="nav-link" style={{ color: '#38bdf8' }} title="Open H2 SQL Database Console">
            SQL Console ↗
          </a>
        </div>

        <div className="nav-actions">
          <div className="search-bar-wrap">
            <span className="search-bar-icon">🔍</span>
            <input
              type="text"
              placeholder="Search gear, cleats, balls..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && fetchProducts()}
            />
          </div>

          <button className="btn-icon-cart" onClick={() => setIsCartOpen(true)} title="View Shopping Cart">
            🛒
            {cartItemCount > 0 && <span className="cart-count-badge">{cartItemCount}</span>}
          </button>

          {user ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
              <span style={{ fontSize: '0.85rem', fontWeight: 600 }}>👤 {user.fullName || user.username}</span>
              <button className="btn-auth" style={{ background: '#334155' }} onClick={logout}>Logout</button>
            </div>
          ) : (
            <button className="btn-auth" onClick={() => { setAuthMode('login'); setIsAuthOpen(true); }}>
              Sign In / JWT
            </button>
          )}
        </div>
      </nav>

      {/* Main Tab Views */}
      {activeTab === 'shop' && (
        <>
          {/* Hero Banner */}
          <section className="hero-banner">
            <div className="hero-content">
              <div className="hero-badge">⚡ Enterprise Pro Grade Software</div>
              <h1 className="hero-title">ENGINEERED FOR <span>CHAMPIONS</span></h1>
              <p className="hero-sub">
                Official athletic equipment, high-performance footwear, and customized team apparel powered by Spring Boot, JPA, and JWT Security.
              </p>
              <div className="hero-stats">
                <div className="stat-item">
                  <h3>100%</h3>
                  <p>PCI-DSS Compliant JWT</p>
                </div>
                <div className="stat-item">
                  <h3>Relational</h3>
                  <p>H2 SQL Database</p>
                </div>
                <div className="stat-item">
                  <h3>&lt; 50ms</h3>
                  <p>Spring Boot REST API</p>
                </div>
              </div>
            </div>
          </section>

          {/* Product Store */}
          <div className="container">
            <div className="filter-bar">
              <div className="category-pills">
                {['All', 'Footwear', 'Apparel', 'Equipment', 'Accessories', 'Teamwear'].map(cat => (
                  <button
                    key={cat}
                    className={`pill ${selectedCategory === cat ? 'active' : ''}`}
                    onClick={() => setSelectedCategory(cat)}
                  >
                    {cat}
                  </button>
                ))}
              </div>

              <div style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
                <span style={{ fontSize: '0.82rem', color: '#94a3b8' }}>Sport:</span>
                <select
                  value={selectedSport}
                  onChange={(e) => setSelectedSport(e.target.value)}
                  style={{
                    background: '#0f172a',
                    color: '#f8fafc',
                    border: '1px solid #243354',
                    borderRadius: '8px',
                    padding: '0.4rem 0.8rem',
                    fontSize: '0.82rem',
                    outline: 'none'
                  }}
                >
                  {['All', 'Soccer', 'Basketball', 'Running', 'Tennis', 'Fitness', 'Baseball'].map(sp => (
                    <option key={sp} value={sp}>{sp}</option>
                  ))}
                </select>
              </div>
            </div>

            {loading ? (
              <div style={{ textAlign: 'center', padding: '4rem', color: '#94a3b8' }}>
                Loading gear from Spring Boot SQL database...
              </div>
            ) : products.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '4rem', color: '#94a3b8' }}>
                No athletic gear found matching your query.
              </div>
            ) : (
              <div className="product-grid">
                {products.map(prod => (
                  <div key={prod.id} className="product-card" onClick={() => setSelectedProduct(prod)}>
                    <div className="product-img-wrap">
                      <img src={prod.imageUrl} alt={prod.name} loading="lazy" />
                      <div className="card-badges">
                        <span className="badge-tag">{prod.sport}</span>
                        {prod.featured && <span className="badge-featured">⭐ Featured</span>}
                      </div>
                    </div>
                    <div className="product-info">
                      <div className="product-meta">
                        <span>{prod.category}</span>
                        <span>⭐ {prod.rating} ({prod.reviewCount})</span>
                      </div>
                      <h3 className="product-title">{prod.name}</h3>
                      <p className="product-desc">{prod.description}</p>
                      <div className="product-footer">
                        <div className="product-price">${prod.price.toFixed(2)}</div>
                        <button
                          className="btn-add-cart"
                          onClick={(e) => {
                            e.stopPropagation();
                            addToCart(prod);
                          }}
                        >
                          + Add to Cart
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </>
      )}

      {/* Uniform Customizer Studio */}
      {activeTab === 'customizer' && (
        <div className="container">
          <div style={{ marginBottom: '1.5rem' }}>
            <h2 style={{ fontFamily: 'Outfit', fontSize: '2rem', fontWeight: 800 }}>
              Team Uniform & Jersey Customizer Studio
            </h2>
            <p style={{ color: '#94a3b8' }}>
              Design customized jerseys for soccer, basketball, and baseball leagues with live tier-based bulk pricing.
            </p>
          </div>

          <div className="customizer-studio">
            {/* Visual Jersey Canvas */}
            <div className="jersey-canvas-box">
              <div className="jersey-mockup" style={{ backgroundColor: customColor }}>
                <div className="jersey-neckline"></div>
                <div className="jersey-player-name">{customName || 'PLAYER'}</div>
                <div className="jersey-player-number">{customNumber || '00'}</div>
              </div>
              <p style={{ marginTop: '1.5rem', fontSize: '0.8rem', color: '#94a3b8' }}>
                Sublimated Moisture-Wicking Pro Poly-Spandex
              </p>
            </div>

            {/* Config Controls */}
            <div>
              <div className="form-group">
                <label className="form-label">Player / Sponsor Name</label>
                <input
                  type="text"
                  maxLength="14"
                  className="form-input"
                  value={customName}
                  onChange={(e) => setCustomName(e.target.value.toUpperCase())}
                  placeholder="e.g. SMITH"
                />
              </div>

              <div className="form-group">
                <label className="form-label">Squad Number (0 - 99)</label>
                <input
                  type="number"
                  min="0"
                  max="99"
                  className="form-input"
                  value={customNumber}
                  onChange={(e) => setCustomNumber(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Team Colorway</label>
                <div className="color-swatches">
                  {['#0284c7', '#dc2626', '#16a34a', '#7c3aed', '#ea580c', '#0f172a'].map(col => (
                    <div
                      key={col}
                      className={`color-swatch ${customColor === col ? 'active' : ''}`}
                      style={{ backgroundColor: col }}
                      onClick={() => setCustomColor(col)}
                    />
                  ))}
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Team Order Quantity (Bulk Discount Tiers)</label>
                <input
                  type="number"
                  min="1"
                  max="500"
                  className="form-input"
                  value={customQty}
                  onChange={(e) => setCustomQty(Math.max(1, parseInt(e.target.value) || 1))}
                />
              </div>

              {customQuote && (
                <div style={{ background: '#070b14', border: '1px solid #243354', borderRadius: '10px', padding: '1.25rem', marginBottom: '1.5rem' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem', fontSize: '0.85rem' }}>
                    <span>Discount Tier:</span>
                    <strong style={{ color: '#10b981' }}>{customQuote.discountTier}</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem', fontSize: '0.85rem' }}>
                    <span>Unit Price:</span>
                    <span>${customQuote.unitPrice.toFixed(2)} / jersey</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.5rem', fontSize: '0.85rem' }}>
                    <span>Total Discount Savings:</span>
                    <span style={{ color: '#10b981' }}>-${customQuote.discountAmount.toFixed(2)} ({customQuote.discountPercentage}%)</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '1.15rem', fontWeight: 800, borderTop: '1px solid #243354', paddingTop: '0.75rem' }}>
                    <span>Estimated Team Total:</span>
                    <span style={{ color: '#38bdf8' }}>${customQuote.finalTotal.toFixed(2)}</span>
                  </div>
                </div>
              )}

              <button
                className="btn-checkout"
                onClick={() => {
                  const customProduct = {
                    id: 999,
                    name: `Custom Uniform (${customName} #${customNumber})`,
                    price: customQuote ? (customQuote.finalTotal / customQty) : 54.99,
                    imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=600&q=80'
                  };
                  addToCart(customProduct, `Name: ${customName}, Number: #${customNumber}, Color: ${customColor}, Qty: ${customQty}`);
                }}
              >
                Add Customized Team Pack to Cart
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Orders List View */}
      {activeTab === 'orders' && (
        <div className="container">
          <h2 style={{ fontFamily: 'Outfit', fontSize: '2rem', fontWeight: 800, marginBottom: '0.5rem' }}>
            My Order History & Real-Time Tracking
          </h2>
          <p style={{ color: '#94a3b8', marginBottom: '2rem' }}>
            Authenticated via Spring Security JWT &bull; Database Records from H2 SQL
          </p>

          {myOrders.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '4rem', background: '#0f172a', border: '1px solid #243354', borderRadius: '12px' }}>
              <p style={{ color: '#94a3b8' }}>You haven't placed any orders yet.</p>
              <button className="btn-auth" style={{ marginTop: '1rem' }} onClick={() => setActiveTab('shop')}>
                Explore Gear Catalog
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              {myOrders.map(ord => (
                <div key={ord.id} style={{ background: '#0f172a', border: '1px solid #243354', borderRadius: '12px', padding: '1.5rem' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid #243354', paddingBottom: '0.75rem', marginBottom: '1rem' }}>
                    <div>
                      <strong style={{ fontSize: '1.05rem', color: '#38bdf8' }}>Order #{ord.orderNumber}</strong>
                      <p style={{ fontSize: '0.8rem', color: '#94a3b8' }}>Placed on {new Date(ord.createdAt).toLocaleDateString()}</p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      <span style={{ background: 'rgba(16, 185, 129, 0.15)', color: '#10b981', padding: '0.3rem 0.75rem', borderRadius: '6px', fontSize: '0.8rem', fontWeight: 700 }}>
                        ● {ord.orderStatus}
                      </span>
                      <p style={{ fontSize: '1.1rem', fontWeight: 800, color: '#f8fafc', marginTop: '0.4rem' }}>
                        ${ord.totalAmount.toFixed(2)}
                      </p>
                    </div>
                  </div>

                  <div>
                    <h4 style={{ fontSize: '0.85rem', color: '#94a3b8', marginBottom: '0.5rem' }}>Items Ordered:</h4>
                    {ord.items && ord.items.map(item => (
                      <div key={item.id} style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', padding: '0.3rem 0' }}>
                        <span>{item.quantity}x {item.product.name} {item.customizationDetails && <em style={{ color: '#38bdf8' }}>({item.customizationDetails})</em>}</span>
                        <span>${(item.unitPrice * item.quantity).toFixed(2)}</span>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Cart Drawer Modal */}
      {isCartOpen && (
        <div className="cart-drawer">
          <div className="cart-header">
            <h3 style={{ fontFamily: 'Outfit', fontSize: '1.2rem', fontWeight: 700 }}>
              Shopping Cart ({cartItemCount})
            </h3>
            <button className="btn-close" onClick={() => setIsCartOpen(false)}>×</button>
          </div>

          <div className="cart-items">
            {cart.length === 0 ? (
              <p style={{ textAlign: 'center', color: '#94a3b8', marginTop: '3rem' }}>Your shopping cart is empty.</p>
            ) : (
              cart.map((item, idx) => (
                <div key={idx} className="cart-item">
                  <img src={item.product.imageUrl} alt="" className="cart-item-img" />
                  <div className="cart-item-details">
                    <div className="cart-item-title">{item.product.name}</div>
                    {item.customization && (
                      <div style={{ fontSize: '0.75rem', color: '#38bdf8', marginBottom: '0.2rem' }}>
                        {item.customization}
                      </div>
                    )}
                    <div className="cart-item-price">${item.product.price.toFixed(2)}</div>
                    <div className="cart-item-qty">
                      <button className="btn-qty" onClick={() => updateQuantity(idx, -1)}>-</button>
                      <span style={{ fontSize: '0.85rem', fontWeight: 700 }}>{item.quantity}</span>
                      <button className="btn-qty" onClick={() => updateQuantity(idx, 1)}>+</button>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {cart.length > 0 && (
            <div className="cart-footer">
              <div className="cart-subtotal">
                <span>Subtotal:</span>
                <span style={{ color: '#38bdf8' }}>${cartSubtotal.toFixed(2)}</span>
              </div>
              <button
                className="btn-checkout"
                onClick={() => {
                  setIsCartOpen(false);
                  setIsCheckoutOpen(true);
                }}
              >
                Proceed to Checkout →
              </button>
            </div>
          )}
        </div>
      )}

      {/* Checkout Modal */}
      {isCheckoutOpen && (
        <div className="modal-overlay" onClick={() => setIsCheckoutOpen(false)}>
          <div className="modal-card" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">Secure Checkout (Spring Boot REST)</h3>
              <button className="btn-close" onClick={() => setIsCheckoutOpen(false)}>×</button>
            </div>

            <form onSubmit={handleCheckout}>
              <div className="form-group">
                <label className="form-label">Shipping Address</label>
                <input
                  type="text"
                  required
                  className="form-input"
                  value={checkoutForm.shippingAddress}
                  onChange={(e) => setCheckoutForm({ ...checkoutForm, shippingAddress: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Payment Method</label>
                <select
                  className="form-input"
                  value={checkoutForm.paymentMethod}
                  onChange={(e) => setCheckoutForm({ ...checkoutForm, paymentMethod: e.target.value })}
                >
                  <option value="CREDIT_CARD">Credit / Debit Card (Stripe Token)</option>
                  <option value="PAYPAL">PayPal Checkout</option>
                  <option value="APPLE_PAY">Apple Pay / Digital Wallet</option>
                </select>
              </div>

              <div style={{ background: '#0b1120', padding: '1rem', borderRadius: '8px', marginBottom: '1.25rem', fontSize: '0.85rem' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.4rem' }}>
                  <span>Total Items:</span>
                  <strong>{cartItemCount}</strong>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '1.1rem', fontWeight: 800 }}>
                  <span>Order Total:</span>
                  <span style={{ color: '#38bdf8' }}>${cartSubtotal.toFixed(2)}</span>
                </div>
              </div>

              <button type="submit" className="btn-checkout">
                Authorize & Place Order
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Auth Modal (Login / Register) */}
      {isAuthOpen && (
        <div className="modal-overlay" onClick={() => setIsAuthOpen(false)}>
          <div className="modal-card" onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <h3 className="modal-title">
                {authMode === 'login' ? 'Customer Sign In' : 'Create Customer Account'}
              </h3>
              <button className="btn-close" onClick={() => setIsAuthOpen(false)}>×</button>
            </div>

            {authError && (
              <div style={{ background: 'rgba(239, 68, 68, 0.15)', color: '#ef4444', padding: '0.6rem 0.8rem', borderRadius: '6px', fontSize: '0.82rem', marginBottom: '1rem' }}>
                {authError}
              </div>
            )}

            <form onSubmit={handleAuthSubmit}>
              {authMode === 'register' && (
                <div className="form-group">
                  <label className="form-label">Full Name</label>
                  <input
                    type="text"
                    required
                    className="form-input"
                    value={authForm.fullName}
                    onChange={(e) => setAuthForm({ ...authForm, fullName: e.target.value })}
                    placeholder="e.g. Alex Morgan"
                  />
                </div>
              )}

              <div className="form-group">
                <label className="form-label">Username</label>
                <input
                  type="text"
                  required
                  className="form-input"
                  value={authForm.username}
                  onChange={(e) => setAuthForm({ ...authForm, username: e.target.value })}
                  placeholder="e.g. athlete99"
                />
              </div>

              {authMode === 'register' && (
                <div className="form-group">
                  <label className="form-label">Email Address</label>
                  <input
                    type="email"
                    required
                    className="form-input"
                    value={authForm.email}
                    onChange={(e) => setAuthForm({ ...authForm, email: e.target.value })}
                    placeholder="alex@epicsports.com"
                  />
                </div>
              )}

              <div className="form-group">
                <label className="form-label">Password</label>
                <input
                  type="password"
                  required
                  className="form-input"
                  value={authForm.password}
                  onChange={(e) => setAuthForm({ ...authForm, password: e.target.value })}
                  placeholder="••••••••"
                />
              </div>

              <button type="submit" className="btn-checkout" style={{ marginBottom: '1rem' }}>
                {authMode === 'login' ? 'Sign In with JWT' : 'Create Account'}
              </button>

              <div style={{ textAlign: 'center', fontSize: '0.85rem', color: '#94a3b8' }}>
                {authMode === 'login' ? (
                  <span>
                    Don't have an account?{' '}
                    <a href="#register" style={{ color: '#38bdf8' }} onClick={(e) => { e.preventDefault(); setAuthMode('register'); }}>
                      Register now
                    </a>
                  </span>
                ) : (
                  <span>
                    Already registered?{' '}
                    <a href="#login" style={{ color: '#38bdf8' }} onClick={(e) => { e.preventDefault(); setAuthMode('login'); }}>
                      Sign in here
                    </a>
                  </span>
                )}
              </div>

              <div style={{ marginTop: '1.25rem', paddingTop: '1rem', borderTop: '1px solid #243354', fontSize: '0.75rem', color: '#94a3b8' }}>
                <strong>Demo Credentials:</strong><br />
                Customer: <code>customer</code> / <code>customer123</code><br />
                Administrator: <code>admin</code> / <code>admin123</code>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Product Detail Modal */}
      {selectedProduct && (
        <div className="modal-overlay" onClick={() => setSelectedProduct(null)}>
          <div className="modal-card" style={{ maxWidth: '650px' }} onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <span className="badge-tag">{selectedProduct.sport}</span>
              <button className="btn-close" onClick={() => setSelectedProduct(null)}>×</button>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.5rem', marginBottom: '1.5rem' }}>
              <img
                src={selectedProduct.imageUrl}
                alt={selectedProduct.name}
                style={{ width: '100%', height: '260px', objectFit: 'cover', borderRadius: '10px' }}
              />
              <div>
                <h3 style={{ fontFamily: 'Outfit', fontSize: '1.3rem', fontWeight: 700, marginBottom: '0.5rem' }}>
                  {selectedProduct.name}
                </h3>
                <div style={{ color: '#38bdf8', fontSize: '1.4rem', fontWeight: 800, marginBottom: '0.75rem' }}>
                  ${selectedProduct.price.toFixed(2)}
                </div>
                <div style={{ fontSize: '0.8rem', color: '#94a3b8', marginBottom: '1rem' }}>
                  In Stock: <strong style={{ color: selectedProduct.stock > 10 ? '#10b981' : '#f59e0b' }}>{selectedProduct.stock} units</strong>
                </div>
                <p style={{ fontSize: '0.85rem', color: '#cbd5e1', lineHeight: '1.5' }}>
                  {selectedProduct.description}
                </p>
              </div>
            </div>

            <button
              className="btn-checkout"
              onClick={() => {
                addToCart(selectedProduct);
                setSelectedProduct(null);
              }}
            >
              Add to Cart (${selectedProduct.price.toFixed(2)})
            </button>
          </div>
        </div>
      )}

      {/* Order Success Toast */}
      {orderSuccess && (
        <div className="modal-overlay" onClick={() => setOrderSuccess(null)}>
          <div className="modal-card" style={{ textAlign: 'center' }} onClick={e => e.stopPropagation()}>
            <div style={{ fontSize: '3rem', marginBottom: '1rem' }}>🎉</div>
            <h3 style={{ fontFamily: 'Outfit', fontSize: '1.5rem', fontWeight: 800, marginBottom: '0.5rem' }}>
              Order Placed Successfully!
            </h3>
            <p style={{ color: '#94a3b8', fontSize: '0.9rem', marginBottom: '1rem' }}>
              Order Number: <strong style={{ color: '#38bdf8' }}>{orderSuccess.orderNumber}</strong>
            </p>
            <p style={{ fontSize: '0.85rem', color: '#cbd5e1', marginBottom: '1.5rem' }}>
              Total Paid: <strong>${orderSuccess.totalAmount.toFixed(2)}</strong> via {orderSuccess.paymentMethod}. Confirmation sent to your profile.
            </p>
            <button className="btn-checkout" onClick={() => { setOrderSuccess(null); setActiveTab('orders'); }}>
              View in My Orders →
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
