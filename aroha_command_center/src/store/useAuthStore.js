import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useAuthStore = create(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      
      login: (operatorId, role) => set({
        user: {
          id: 'OP-778',
          email: operatorId,
          role: role,
          name: 'Cmdr. Alex',
          station: role === 'MANAGER' ? 'Bharati Station' : 'NCPOR Central'
        },
        isAuthenticated: true,
      }),
      
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    {
      name: 'aroha-auth-storage', // The key used in localStorage
    }
  )
);

export default useAuthStore;