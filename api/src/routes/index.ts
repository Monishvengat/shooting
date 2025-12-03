import { Router } from 'express';
import IndexController from '../controllers/index';

const router = Router();
const indexController = new IndexController();

router.get('/api/data', indexController.getData);
router.post('/api/data', indexController.createData);

export default router;