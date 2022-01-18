import {logger} from '@/plugins/logger';
import {ActionTree, GetterTree, MutationTree} from 'vuex';
import {firestoreAction} from 'vuexfire';
import {RootState} from './root.store';

const namespace = 'auth';
const log = logger(namespace);

export interface State {
  Initialized: boolean;
  Data: any;
}

export const state = (): State => ({
  Initialized: false,
  Data: null,
});

export const AUTH_ACTIONS = {
  initialize: 'initialize',
  bindData: 'bindData',
};

export const AUTH_MUTATIONS = {
  SET_INITIALIZED: 'SET_INITIALIZED',
};

export const getters: GetterTree<State, RootState> = {};

export interface StoreExtra {
  auth: firebase.auth.Auth;
  firestore: firebase.firestore.Firestore;
}

export const actions = (extra: StoreExtra): ActionTree<State, RootState> => {
  return {
    [AUTH_ACTIONS.initialize]: async ({commit, state, dispatch}) => {
      commit(AUTH_MUTATIONS.SET_INITIALIZED);
      log('inited');
    },
    [AUTH_ACTIONS.bindData]: firestoreAction(({state, bindFirestoreRef}) => {
      if (state.Data) {
        return bindFirestoreRef(
          'Data',
          extra.firestore.collection('data').doc('doc_id'),
        );
      }
    }),
  };
};

export const mutations: MutationTree<State> = {
  [AUTH_MUTATIONS.SET_INITIALIZED](state) {
    state.Initialized = true;
  },
};

export const store = (params: {initialState: State; extra: StoreExtra}) => ({
  namespaced: true,
  state: params.initialState,
  getters,
  actions: actions(params.extra),
  mutations: mutations,
});
