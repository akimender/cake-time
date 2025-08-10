import { useState, useEffect } from 'react';
import './HomePage.css';

const HomePage = ({ user }) => {
  const [cakes, setCakes] = useState([]);
  const [showAddForm, setShowAddForm] = useState(false);
  const [editingCake, setEditingCake] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    flavor: '',
    price: '',
    description: ''
  });

  // Mock initial data
  useEffect(() => {
    const mockCakes = [
      {
        id: 1,
        name: 'Chocolate Cake',
        flavor: 'Chocolate',
        price: 25.99,
        description: 'Rich and moist chocolate cake with chocolate frosting'
      },
      {
        id: 2,
        name: 'Vanilla Cake',
        flavor: 'Vanilla',
        price: 22.99,
        description: 'Classic vanilla cake with vanilla buttercream'
      }
    ];
    setCakes(mockCakes);
  }, []);

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (editingCake) {
      // Update existing cake
      setCakes(cakes.map(cake => 
        cake.id === editingCake.id 
          ? { ...cake, ...formData, price: parseFloat(formData.price) }
          : cake
      ));
      setEditingCake(null);
    } else {
      // Add new cake
      const newCake = {
        id: Date.now(),
        ...formData,
        price: parseFloat(formData.price)
      };
      setCakes([...cakes, newCake]);
    }
    
    // Reset form
    setFormData({
      name: '',
      flavor: '',
      price: '',
      description: ''
    });
    setShowAddForm(false);
  };

  const handleEdit = (cake) => {
    setEditingCake(cake);
    setFormData({
      name: cake.name,
      flavor: cake.flavor,
      price: cake.price.toString(),
      description: cake.description
    });
    setShowAddForm(true);
  };

  const handleDelete = (cakeId) => {
    if (window.confirm('Are you sure you want to delete this cake?')) {
      setCakes(cakes.filter(cake => cake.id !== cakeId));
    }
  };

  const handleCancel = () => {
    setShowAddForm(false);
    setEditingCake(null);
    setFormData({
      name: '',
      flavor: '',
      price: '',
      description: ''
    });
  };

  return (
    <div className="home-page">
      <div className="home-header">
        <h1>Welcome back, {user?.name}!</h1>
        <p>Manage your delicious cake collection</p>
      </div>

      <div className="home-content">
        <div className="cakes-header">
          <h2>Your Cakes</h2>
          <button 
            className="btn btn-primary"
            onClick={() => setShowAddForm(true)}
          >
            Add New Cake
          </button>
        </div>

        {showAddForm && (
          <div className="cake-form-container">
            <h3>{editingCake ? 'Edit Cake' : 'Add New Cake'}</h3>
            <form onSubmit={handleSubmit} className="cake-form">
              <div className="form-group">
                <label htmlFor="name">Cake Name</label>
                <input
                  type="text"
                  id="name"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  required
                  placeholder="Enter cake name"
                />
              </div>

              <div className="form-group">
                <label htmlFor="flavor">Flavor</label>
                <input
                  type="text"
                  id="flavor"
                  name="flavor"
                  value={formData.flavor}
                  onChange={handleChange}
                  required
                  placeholder="Enter cake flavor"
                />
              </div>

              <div className="form-group">
                <label htmlFor="price">Price ($)</label>
                <input
                  type="number"
                  id="price"
                  name="price"
                  value={formData.price}
                  onChange={handleChange}
                  required
                  step="0.01"
                  min="0"
                  placeholder="Enter price"
                />
              </div>

              <div className="form-group">
                <label htmlFor="description">Description</label>
                <textarea
                  id="description"
                  name="description"
                  value={formData.description}
                  onChange={handleChange}
                  required
                  placeholder="Enter cake description"
                  rows="3"
                />
              </div>

              <div className="form-actions">
                <button type="submit" className="btn btn-primary">
                  {editingCake ? 'Update Cake' : 'Add Cake'}
                </button>
                <button 
                  type="button" 
                  className="btn btn-secondary"
                  onClick={handleCancel}
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        )}

        <div className="cakes-grid">
          {cakes.length === 0 ? (
            <div className="no-cakes">
              <p>No cakes yet. Add your first cake!</p>
            </div>
          ) : (
            cakes.map(cake => (
              <div key={cake.id} className="cake-card">
                <div className="cake-info">
                  <h3>{cake.name}</h3>
                  <p className="cake-flavor">Flavor: {cake.flavor}</p>
                  <p className="cake-price">${cake.price}</p>
                  <p className="cake-description">{cake.description}</p>
                </div>
                <div className="cake-actions">
                  <button 
                    className="btn btn-small btn-secondary"
                    onClick={() => handleEdit(cake)}
                  >
                    Edit
                  </button>
                  <button 
                    className="btn btn-small btn-danger"
                    onClick={() => handleDelete(cake.id)}
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default HomePage;
