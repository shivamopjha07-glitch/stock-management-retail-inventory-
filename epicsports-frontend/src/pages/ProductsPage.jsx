import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Search, SlidersHorizontal, X, ChevronDown } from 'lucide-react';
import { productApi } from '../api/client';
import ProductCard from '../components/ProductCard';

const ProductsPage = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const [search, setSearch] = useState(searchParams.get('search') || '');
  const [selectedCategory, setSelectedCategory] = useState(searchParams.get('category') || 'All');
  const [selectedSport, setSelectedSport] = useState(searchParams.get('sport') || 'All');
  const [filterOpen, setFilterOpen] = useState(false);

  const { data: categoriesData } = useQuery({
    queryKey: ['categories'],
    queryFn: () => productApi.getCategories(),
    staleTime: Infinity,
  });

  const { data: sportsData } = useQuery({
    queryKey: ['sports'],
    queryFn: () => productApi.getSports(),
    staleTime: Infinity,
  });

  const queryParams = {};
  if (search) queryParams.search = search;
  if (selectedCategory && selectedCategory !== 'All') queryParams.category = selectedCategory;
  if (selectedSport && selectedSport !== 'All') queryParams.sport = selectedSport;
  if (searchParams.get('featured') === 'true') queryParams.featured = true;

  const { data, isLoading, isError } = useQuery({
    queryKey: ['products', queryParams],
    queryFn: () => productApi.getAll(queryParams),
    staleTime: 2 * 60 * 1000,
  });

  const products = data?.data?.data || [];
  const categories = categoriesData?.data?.data || ['All', 'Footwear', 'Apparel', 'Equipment', 'Accessories', 'Teamwear'];
  const sports = sportsData?.data?.data || ['All', 'Soccer', 'Basketball', 'Running', 'Baseball', 'Fitness'];

  const handleSearch = (e) => {
    e.preventDefault();
    setSelectedCategory('All');
    setSelectedSport('All');
  };

  const clearFilters = () => {
    setSearch('');
    setSelectedCategory('All');
    setSelectedSport('All');
    setSearchParams({});
  };

  const hasFilters = search || selectedCategory !== 'All' || selectedSport !== 'All';

  return (
    <div className="products-page">
      <div className="container">
        {/* Page Header */}
        <div className="page-header">
          <h1>Shop All Products</h1>
          <p>{products.length} products found</p>
        </div>

        {/* Filters Bar */}
        <div className="filters-bar">
          {/* Search */}
          <form onSubmit={handleSearch} className="search-form" id="product-search-form">
            <div className="search-input-wrap">
              <Search size={18} className="search-icon" />
              <input
                id="product-search-input"
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search products..."
                className="search-input"
              />
              {search && (
                <button type="button" className="search-clear" onClick={() => setSearch('')}>
                  <X size={16} />
                </button>
              )}
            </div>
          </form>

          {/* Filter Toggle Mobile */}
          <button
            className="filter-toggle mobile-only"
            onClick={() => setFilterOpen(!filterOpen)}
            id="filter-toggle-btn"
          >
            <SlidersHorizontal size={18} />
            Filters
            <ChevronDown size={16} className={filterOpen ? 'rotated' : ''} />
          </button>

          {/* Category Filters - Desktop */}
          <div className={`filter-groups ${filterOpen ? 'open' : ''}`}>
            <div className="filter-group">
              <label>Category</label>
              <div className="filter-chips">
                {categories.map((cat) => (
                  <button
                    key={cat}
                    className={`filter-chip ${selectedCategory === cat ? 'active' : ''}`}
                    onClick={() => setSelectedCategory(cat)}
                    id={`category-${cat.toLowerCase()}`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            <div className="filter-group">
              <label>Sport</label>
              <div className="filter-chips">
                {sports.map((sport) => (
                  <button
                    key={sport}
                    className={`filter-chip ${selectedSport === sport ? 'active' : ''}`}
                    onClick={() => setSelectedSport(sport)}
                    id={`sport-${sport.toLowerCase()}`}
                  >
                    {sport}
                  </button>
                ))}
              </div>
            </div>

            {hasFilters && (
              <button className="clear-filters-btn" onClick={clearFilters} id="clear-filters-btn">
                <X size={14} /> Clear Filters
              </button>
            )}
          </div>
        </div>

        {/* Products Grid */}
        {isLoading ? (
          <div className="products-skeleton">
            {[...Array(8)].map((_, i) => (
              <div key={i} className="skeleton-card">
                <div className="skeleton skeleton-img" />
                <div className="skeleton skeleton-text" />
                <div className="skeleton skeleton-text short" />
                <div className="skeleton skeleton-text" />
              </div>
            ))}
          </div>
        ) : isError ? (
          <div className="error-state">
            <p>Failed to load products. Make sure the backend is running on port 8080.</p>
            <button className="btn-primary" onClick={() => window.location.reload()}>Retry</button>
          </div>
        ) : products.length === 0 ? (
          <div className="empty-state">
            <Search size={60} />
            <h3>No products found</h3>
            <p>Try adjusting your search or filters</p>
            <button className="btn-primary" onClick={clearFilters} id="reset-filters-btn">Reset Filters</button>
          </div>
        ) : (
          <div className="products-grid">
            {products.map((product) => (
              <ProductCard key={product.id} product={product} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default ProductsPage;
