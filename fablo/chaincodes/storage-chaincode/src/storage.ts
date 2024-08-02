/*
  SPDX-License-Identifier: Apache-2.0
*/

import {Object, Property} from 'fabric-contract-api';

@Object()
export class Storage {
    @Property()
    public id: string;

    @Property()
    public id_perangkat: string;

    @Property()
    public ppm_mq_135: string;

    @Property()
    public ppm_mq_7: string;

    @Property()
    public created_at: string;

    @Property()
    public updated_at: string;
}
