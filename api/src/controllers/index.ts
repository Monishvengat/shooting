import { Request, Response } from 'express';

class IndexController {
    public async getData(req: Request, res: Response): Promise<void> {
        try {
            // Logic to retrieve data from the database
            res.status(200).json({ message: 'Data retrieved successfully' });
        } catch (error) {
            res.status(500).json({ message: 'Error retrieving data', error });
        }
    }

    public async postData(req: Request, res: Response): Promise<void> {
        try {
            // Logic to save data to the database
            res.status(201).json({ message: 'Data saved successfully' });
        } catch (error) {
            res.status(500).json({ message: 'Error saving data', error });
        }
    }
}

export default new IndexController();