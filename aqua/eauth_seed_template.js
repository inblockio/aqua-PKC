'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.bulkInsert('oauth_clients', [{
        client_id: 'pkc',
        client_secret: 'pkc',
        redirect_uri: 'PKC_SERVER/index.php/Special:OAuth2Client/callback',
      }], {});
  },

  down: (queryInterface, Sequelize) => {
    return queryInterface.bulkDelete('oauth_clients', null, {});
  }
};
