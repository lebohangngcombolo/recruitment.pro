from app.extensions import mongo_db

class CVParsingResult:
    collection = mongo_db.cv_parsing_results
    
    @classmethod
    def create(cls, candidate_id, cv_text, parsed_data):
        document = {
            'candidate_id': candidate_id,
            'cv_text': cv_text,
            'parsed_data': parsed_data,
            'created_at': datetime.utcnow()
        }
        return cls.collection.insert_one(document)
    
    @classmethod
    def get_by_candidate_id(cls, candidate_id):
        return cls.collection.find_one({'candidate_id': candidate_id})

class CVSearchIndex:
    collection = mongo_db.cv_search_index
    
    @classmethod
    def create_index(cls, candidate_id, cv_text, skills, experience):
        document = {
            'candidate_id': candidate_id,
            'cv_text': cv_text,
            'skills': skills,
            'experience': experience,
            'indexed_at': datetime.utcnow()
        }
        return cls.collection.insert_one(document)
    
    @classmethod
    def search(cls, query, skills=None, min_experience=None):
        search_filter = {'$text': {'$search': query}}
        
        if skills:
            search_filter['skills'] = {'$in': skills}
        
        if min_experience:
            search_filter['experience.years'] = {'$gte': min_experience}
        
        return cls.collection.find(search_filter)