import { create } from 'zustand';
import { authApi } from '../api/client';

const useAuthStore = create((set, get) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: true,

  initAuth: async () => {
    const token = localStorage.getItem('epicsports_token');
    const userStr = localStorage.getItem('epicsports_user');
    if (token && userStr) {
      try {
        const user = JSON.parse(userStr);
        set({ token, user, isAuthenticated: true, isLoading: false });
        // Verify token is still valid
        await authApi.getMe();
      } catch {
        get().logout();
      }
    } else {
      set({ isLoading: false });
    }
  },

  login: async (credentials) => {
    const res = await authApi.login(credentials);
    const { token, username, email, fullName, role } = res.data.data;
    const user = { username, email, fullName, role };
    localStorage.setItem('epicsports_token', token);
    localStorage.setItem('epicsports_user', JSON.stringify(user));
    set({ token, user, isAuthenticated: true });
    return user;
  },

  register: async (data) => {
    const res = await authApi.register(data);
    const { token, username, email, fullName, role } = res.data.data;
    const user = { username, email, fullName, role };
    localStorage.setItem('epicsports_token', token);
    localStorage.setItem('epicsports_user', JSON.stringify(user));
    set({ token, user, isAuthenticated: true });
    return user;
  },

  logout: () => {
    localStorage.removeItem('epicsports_token');
    localStorage.removeItem('epicsports_user');
    set({ token: null, user: null, isAuthenticated: false, isLoading: false });
  },
}));

export default useAuthStore;
