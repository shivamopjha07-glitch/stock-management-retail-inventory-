import React from 'react';
import { ShoppingCart, Star, Zap } from 'lucide-react';
import useCartStore from '../store/cartStore';
import toast from 'react-hot-toast';

const ProductCard = ({ product }) => {
  const { addItem } = useCartStore();

  const handleAddToCart = (e) => {
    e.preventDefault();
    e.stopPropagation();
    addItem(product);
    toast.success(`${product.name} added to cart!`, {
      icon: '🛒',
      style: {
        background: '#1a1a2e',
        color: '#e2e8f0',
        border: '1px solid rgba(233, 69, 96, 0.3)',
      },
    });
  };

  const discount = product.originalPrice
    ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)
    : null;

  return (
    <div className="product-card" id={`product-card-${product.id}`}>
      {/* Image */}
      <div className="product-img-wrap">
        <img
          src={product.imageUrl || `https://placehold.co/300x300/1a1a2e/e94560?text=${encodeURIComponent(product.name.substring(0, 2))}`}
          alt={product.name}
          className="product-img"
          loading="lazy"
        />
        {product.featured && (
          <span className="badge badge-featured">
            <Zap size={12} /> Featured
          </span>
        )}
        {discount && (
          <span className="badge badge-discount">-{discount}%</span>
        )}
        {product.stock <= 5 && product.stock > 0 && (
          <span className="badge badge-low-stock">Only {product.stock} left</span>
        )}
        {product.stock === 0 && (
          <span className="badge badge-out-of-stock">Out of Stock</span>
        )}
        <div className="product-overlay">
          <button
            className="quick-add-btn"
            onClick={handleAddToCart}
            disabled={product.stock === 0}
            id={`add-to-cart-${product.id}`}
          >
            <ShoppingCart size={16} />
            {product.stock === 0 ? 'Out of Stock' : 'Add to Cart'}
          </button>
        </div>
      </div>

      {/* Info */}
      <div className="product-info">
        <div className="product-meta">
          <span className="product-category">{product.category}</span>
          <span className="product-sport">{product.sport}</span>
        </div>
        <h3 className="product-name">{product.name}</h3>
        <p className="product-desc">{product.description?.substring(0, 80)}...</p>

        <div className="product-rating">
          {[...Array(5)].map((_, i) => (
            <Star key={i} size={14} className={i < 4 ? 'star-filled' : 'star-empty'} />
          ))}
          <span>(4.0)</span>
        </div>

        <div className="product-price-row">
          <div className="price-group">
            <span className="product-price">${product.price.toFixed(2)}</span>
            {product.originalPrice && (
              <span className="product-original-price">${product.originalPrice.toFixed(2)}</span>
            )}
          </div>
          <button
            className="add-cart-icon-btn"
            onClick={handleAddToCart}
            disabled={product.stock === 0}
            id={`add-cart-icon-${product.id}`}
            title="Add to cart"
          >
            <ShoppingCart size={18} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;
